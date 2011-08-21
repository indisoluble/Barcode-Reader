//
//  CaptureBarcodeViewController.m
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 24/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import "CaptureBarcodeViewController.h"
#import "CaptureModel.h"

#import <Ice/Ice.h>
#import <Barcode.h>



typedef enum {
	CaptureBarcodePriceFound,
	CaptureBarcodePriceNotFound,
	CaptureBarcodePriceError
} ResultGetPriceType;



#define CAPTUREBARCODE_IMAGESIZE 100



@interface CaptureBarcodeViewController ()


#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


#pragma mark -
#pragma mark Methods
- (void)saveBarcode:(NSString *)barcode image:(UIImage *)image;

- (ResultGetPriceType)getPriceRemotelyForBarcode:(NSString *)barcode price:(NSNumber **)price;

- (BOOL)createLocallyBarcode:(NSString *)barcode image:(UIImage *)image price:(NSNumber *)price;

- (void)askForDataToCreateBarcodeRemotely;

- (UIImage *)resize:(UIImage *)image;
- (void)showSimpleAlertWithTitle:(NSString *)tt message:(NSString *)msg;

@end



@implementation CaptureBarcodeViewController


#pragma mark -
#pragma mark Synthesized methods
@synthesize managedObjectContext = __managedObjectContext;

@synthesize resultImage = __resultImage;
@synthesize resultText = __resultText;


#pragma mark -
#pragma mark Init object
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil managedObjectContext:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
 managedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Capture";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title
                                                         image:[UIImage imageNamed:@"86-camera.png"]
                                                           tag:0] autorelease];
        self.managedObjectContext = moc;
    }
    return self;
}


#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    self.resultImage = nil;
    self.resultText = nil;
    
    self.managedObjectContext = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
	NSLog(@"End scanning");
	
    // Get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) {
        // Just grab the first barcode
        break;
    }
    
    // Show the barcode data and image
    self.resultText.text = symbol.data;
    self.resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
	
	// Dismiss the controller
    [reader dismissModalViewControllerAnimated: YES];
	
    // Save data
	[self saveBarcode:self.resultText.text image:self.resultImage.image];
}


#pragma mark -
#pragma mark DefineBarcodeDelegate methods
- (void)useBarcodeWithDescription:(NSString *)desc price:(NSNumber *)price
{
	// Save barcoce locally
	[self createLocallyBarcode:self.resultText.text image:self.resultImage.image price:price];

	// Dismiss actual view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)discardBarcode
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Public methods
- (IBAction)scanButtonTapped
{
    NSLog(@"Start scanning ...");
    
    // Present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [[[ZBarReaderViewController alloc] init] autorelease];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    // Present the controller
    [self presentModalViewController:reader animated:YES];
}


#pragma mark -
#pragma mark Private methods
- (void)saveBarcode:(NSString *)barcode image:(UIImage *)image
{
	NSNumber *price = nil;
	
	NSLog(@"Save capture to database (if possible)");
	
	switch ([self getPriceRemotelyForBarcode:barcode price:&price]) {
		case CaptureBarcodePriceFound:
			NSLog(@"Price found for barcode <%@>. Save right now", barcode);
			[self createLocallyBarcode:barcode image:image price:price];
			
			break;			
		case CaptureBarcodePriceNotFound:
			NSLog(@"Price not found for barcode <%@>. Create remotelly?", barcode);
			[self askForDataToCreateBarcodeRemotely];
			
			break;
		default:
			break;
	}
	
}

- (ResultGetPriceType)getPriceRemotelyForBarcode:(NSString *)barcode price:(NSNumber **)price;
{
	NSString *pListPath;
	NSData *pListData;
	NSDictionary *pListDictionary;
	
	NSString *serverIp;
	NSNumber *serverPort;	
	
	int priceInt = -1;
	ResultGetPriceType result = CaptureBarcodePriceNotFound;
	
	NSLog(@"Get price from server");
	
	// Get connection data
	pListPath =  [[NSBundle mainBundle] pathForResource:@"BarcodeReaderClientXcode3-Properties" ofType:@"plist"];
	pListData = [[[NSData alloc] initWithContentsOfFile:pListPath] autorelease];
	pListDictionary = (NSDictionary *) [NSPropertyListSerialization propertyListWithData:pListData
																				 options:0
																				  format:nil
																				   error:nil];
	
	serverIp = [pListDictionary objectForKey:@"ServerIp"];
	serverPort = [pListDictionary objectForKey:@"ServerPort"];;
	
	// Dowload data
	id<ICECommunicator> communicator = nil;
	@try {
		communicator = [ICEUtil createCommunicator];
		id<ICEObjectPrx> base = [communicator stringToProxy:
								 [NSString stringWithFormat:@"BarcodeRemoteDB:tcp -h %@ -p %@",serverIp, serverPort]];
		id<DemoBarcodePrx> barcodeDB = [DemoBarcodePrx checkedCast:base];
		
		priceInt = [barcodeDB priceForBarcode:barcode];
		result = (priceInt < 0 ? CaptureBarcodePriceNotFound : CaptureBarcodePriceFound);
		if (result == CaptureBarcodePriceFound) {
			*price = [NSNumber numberWithInt:priceInt];
		}
	}
	@catch (NSException * ex) {
		result = CaptureBarcodePriceError;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Getting price for barcode" message:[ex reason]];
	}
	
	// Finish connection
	@try {
		[communicator destroy];
	}
	@catch (NSException * ex) {
		result = CaptureBarcodePriceError;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Destroying conection" message:[ex reason]];
	}
	
	return result;
}

- (BOOL)createLocallyBarcode:(NSString *)barcode image:(UIImage *)image price:(NSNumber *)price
{
	BOOL result = NO;
	
	if (self.managedObjectContext) {
		
		CaptureModel *capture = (CaptureModel *)[NSEntityDescription insertNewObjectForEntityForName:@"CaptureModel"
																			  inManagedObjectContext:self.managedObjectContext];
		capture.barcode = barcode;
		capture.image = UIImagePNGRepresentation([self resize:image]);
		capture.price = price;
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Error saving data <%@>", error);
			[self showSimpleAlertWithTitle:@"Creating locally barcode" message:[error localizedFailureReason]];
		}
		else {
			result = YES;
			NSLog(@"Data saved: <%@, %@>", capture.barcode, capture.price);
		}
		
	}
	
	if (result) {
		NSLog(@"Barcode <%@> with price <%@> saved", barcode, price);
	}
	
	return result;
}

- (void)askForDataToCreateBarcodeRemotely
{
	NSLog(@"Show view to ask");
	
	DefineBarcodeViewController *defineBarcodeViewController =
	[[[DefineBarcodeViewController alloc] initWithNibName:@"DefineBarcodeViewController"
												   bundle:nil
												  barcode:self.resultText.text
													image:[self resize:self.resultImage.image]] autorelease];
	
	// #warning Incorrect, two modal view in a row it's not a good idea
	// [self presentModalViewController:defineBarcodeViewController animated:YES];

	defineBarcodeViewController.delegate = self;
	[self.navigationController pushViewController:defineBarcodeViewController animated:YES];
}

- (UIImage *)resize:(UIImage *)image
{
    UIImage *imageResized = nil;
    
    if (image.size.width != CAPTUREBARCODE_IMAGESIZE &&
        image.size.height != CAPTUREBARCODE_IMAGESIZE)
    {
        CGSize itemSize = CGSizeMake(CAPTUREBARCODE_IMAGESIZE, CAPTUREBARCODE_IMAGESIZE);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        imageResized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        imageResized = image;
    }
	
    return imageResized;
}

- (void)showSimpleAlertWithTitle:(NSString *)tt message:(NSString *)msg
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tt
														message:msg
													   delegate:nil
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}



@end
