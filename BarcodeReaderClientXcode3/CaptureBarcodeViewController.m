//
//  CaptureBarcodeViewController.m
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 24/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import "CaptureBarcodeViewController.h"
#import "CaptureModel.h"



#define CAPTUREBARCODE_IMAGESIZE 48



@interface CaptureBarcodeViewController ()

#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

#pragma mark - Methods
- (UIImage *)resize:(UIImage *)image;

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
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
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
    if (self.managedObjectContext) {
        
        NSLog(@"Save capture to database");
		
        CaptureModel *capture = (CaptureModel *)[NSEntityDescription insertNewObjectForEntityForName:@"CaptureModel"
                                                                              inManagedObjectContext:self.managedObjectContext];
        capture.barcode = self.resultText.text;
        capture.image = UIImageJPEGRepresentation([self resize:self.resultImage.image], 1.0);
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error saving data downloaded from server <%@>", error);
        }
        
    }
    
    // Dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    NSLog(@"End scanning");
}


#pragma mark -
#pragma mark Private methods
- (IBAction) scanButtonTapped
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



@end
