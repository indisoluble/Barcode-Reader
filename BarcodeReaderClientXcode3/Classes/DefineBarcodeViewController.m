//
//  DefineBarcodeViewController.m
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 08/08/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import "DefineBarcodeViewController.h"

#import <Ice/Ice.h>
#import <Barcode.h>



@interface DefineBarcodeViewController()

#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSString *barcodeText;
@property (nonatomic, retain) UIImage *barcodeImage;

#pragma mark -
#pragma mark Methods
- (BOOL)createRemotelyBarcode:(NSString *)barcode
				  description:(NSString *)desc
						price:(NSNumber *)price 
						image:(UIImage *)image;
- (void)showSimpleAlertWithTitle:(NSString *)tt message:(NSString *)msg;

@end



@implementation DefineBarcodeViewController


#pragma mark -
#pragma mark Synthesized methods
@synthesize barcodeDescription = __barcodeDescription;
@synthesize barcodePrice = __barcodePrice;

@synthesize barcodeText = __barcodeText;
@synthesize barcodeImage = __barcodeImage;

@synthesize delegate = __delegate;


#pragma mark -
#pragma mark Init object
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil barcode:nil image:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
			  barcode:(NSString *)barcode
				image:(UIImage *)image
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"New barcoce";
		self.barcodeText = barcode;
		self.barcodeImage = image;
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
	self.barcodeDescription = nil;
	self.barcodePrice = nil;
	
	self.barcodeText = nil;
	self.barcodeImage = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle
/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	return YES;
}


#pragma mark -
#pragma mark Public methods
- (IBAction)useData
{
	if (self.delegate != nil &&
		self.barcodeText != nil &&
		self.barcodeImage != nil) {
		// Create barcode remotelly
		if ([self createRemotelyBarcode:self.barcodeText
							description:self.barcodeDescription.text
								  price:[NSNumber numberWithInteger:[self.barcodePrice.text integerValue]]
								  image:self.barcodeImage]) {
			[self.delegate useBarcodeWithDescription:self.barcodeDescription.text
											   price:[NSNumber numberWithInteger:[self.barcodePrice.text integerValue]]];
		}
		else {
			[self.delegate discardBarcode];
		}
	}
	else {
		[self showSimpleAlertWithTitle:@"Creating barcode in server" message:@"No data"];
	}

}


#pragma mark -
#pragma mark Private methods
- (BOOL)createRemotelyBarcode:(NSString *)barcode
				  description:(NSString *)desc
						price:(NSNumber *)price 
						image:(UIImage *)image
{
	NSString *pListPath;
	NSData *pListData;
	NSDictionary *pListDictionary;
	
	NSString *serverIp;
	NSNumber *serverPort;
	
	BOOL result = YES;
	
	NSLog(@"Creating barcode in server");
	
	// Get connection data
	pListPath =  [[NSBundle mainBundle] pathForResource:@"BarcodeReaderClientXcode3-Properties" ofType:@"plist"];
	pListData = [[[NSData alloc] initWithContentsOfFile:pListPath] autorelease];
	pListDictionary = (NSDictionary *) [NSPropertyListSerialization propertyListWithData:pListData
																				 options:0
																				  format:nil
																				   error:nil];
	
	serverIp = [pListDictionary objectForKey:@"ServerIp"];
	serverPort = [pListDictionary objectForKey:@"ServerPort"];;
	
	// Upload data
	id<ICECommunicator> communicator = nil;
	@try {
		communicator = [ICEUtil createCommunicator];
		id<ICEObjectPrx> base = [communicator stringToProxy:
								 [NSString stringWithFormat:@"BarcodeRemoteDB:tcp -h %@ -p %@",serverIp, serverPort]];
		id<DemoBarcodePrx> barcodeDB = [DemoBarcodePrx checkedCast:base];

		result = ([barcodeDB saveProduct:barcode desc:desc price:[price intValue] image:UIImagePNGRepresentation(image)] < 0 ? NO : YES);
	}
	@catch (NSException * ex) {
		result = NO;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Creating barcode in server" message:[ex reason]];
	}
	
	// Finish connection
	@try {
		[communicator destroy];
	}
	@catch (NSException * ex) {
		result = NO;
		NSLog(@"%@", ex);
		[self showSimpleAlertWithTitle:@"Destroying conection" message:[ex reason]];
	}
	
	return result;	
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
