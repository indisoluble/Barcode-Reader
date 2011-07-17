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
#warning Change IP depending on your test
#define CAPTUREBARCODE_IP "XXX.XXX.XXX.XXX"
#define CAPTUREBARCODE_PORT 10000



@interface CaptureBarcodeViewController ()


#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


#pragma mark -
#pragma mark Methods
- (void)saveBarcode:(NSString *)barcode image:(UIImage *)image;

- (ResultGetPriceType)getPriceRemotelyForBarcode:(NSString *)barcode price:(NSNumber **)price;

- (BOOL)createLocallyBarcode:(NSString *)barcode image:(UIImage *)image price:(NSNumber *)price;
- (BOOL)createRemotelyBarcode:(NSString *)barcode image:(UIImage *)image getPrice:(NSNumber **)price;

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
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
    
    // Save data
	[self saveBarcode:self.resultText.text image:self.resultImage.image];
	
    // Dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    NSLog(@"End scanning");
}


#pragma mark -
#pragma mark Private methods
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

- (void)saveBarcode:(NSString *)barcode image:(UIImage *)image
{
	NSNumber *price = nil;
	
	NSLog(@"Save capture to database");
	
	switch ([self getPriceRemotelyForBarcode:barcode price:&price]) {
		case CaptureBarcodePriceNotFound:
			if (![self createRemotelyBarcode:barcode image:image getPrice:&price]) {
				break;
			}
			
		case CaptureBarcodePriceFound:
			[self createLocallyBarcode:barcode image:image price:price];
			
			break;
		default:
			break;
	}
	
}

- (ResultGetPriceType)getPriceRemotelyForBarcode:(NSString *)barcode price:(NSNumber **)price;
{
	int priceInt = -1;
	ResultGetPriceType result = CaptureBarcodePriceNotFound;
	
	NSLog(@"Get price from server");
	
	id<ICECommunicator> communicator = nil;
	@try {
		communicator = [ICEUtil createCommunicator];
		id<ICEObjectPrx> base = [communicator stringToProxy:
								 [NSString stringWithFormat:@"BarcodeRemoteDB:tcp -h %s -p %d",CAPTUREBARCODE_IP, CAPTUREBARCODE_PORT]];
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
	
	return result;
}

- (BOOL)createRemotelyBarcode:(NSString *)barcode image:(UIImage *)image getPrice:(NSNumber **)price
{
	NSString *descAux = nil;
	int priceAux = -1;
	NSData *imageAux = nil;
	
	BOOL result = YES;
	
	NSLog(@"Creating barcode in server");
	
	id<ICECommunicator> communicator = nil;
	@try {
		communicator = [ICEUtil createCommunicator];
		id<ICEObjectPrx> base = [communicator stringToProxy:
								 [NSString stringWithFormat:@"BarcodeRemoteDB:tcp -h %s -p %d",CAPTUREBARCODE_IP, CAPTUREBARCODE_PORT]];
		id<DemoBarcodePrx> barcodeDB = [DemoBarcodePrx checkedCast:base];
		
		descAux = @"Test iOS";
		priceAux = 7777;
		imageAux = UIImagePNGRepresentation([self resize:image]);
		
		result = ([barcodeDB saveProduct:barcode desc:descAux price:priceAux image:imageAux] < 0 ? NO : YES);
	}
	@catch (NSException * ex) {
		result = NO;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Creating barcode in server" message:[ex reason]];
	}
	
	@try {
		[communicator destroy];
	}
	@catch (NSException * ex) {
		result = NO;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Destroying conection" message:[ex reason]];
	}
	
	if (result) {
		*price = [NSNumber numberWithInt:priceAux];;
	}
	
	return result;	
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
