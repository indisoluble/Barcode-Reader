//
//  CaptureBarcodeViewController.m
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import "CaptureBarcodeViewController.h"



@interface CaptureBarcodeViewController ()

#pragma mark - Methods
- (IBAction) scanButtonTapped;

@end



@implementation CaptureBarcodeViewController


#pragma mark - Synthesized methods
@synthesize resultImage = __resultImage;
@synthesize resultText = __resultText;


#pragma mark - Init object
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Capture";
    }
    return self;
}


#pragma mark - Memory management
- (void)dealloc
{
    self.resultImage = nil;
    self.resultText = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle
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


#pragma mark - UIImagePickerControllerDelegate methods
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
    {
        // EXAMPLE: just grab the first barcode
        break;
    }
    
    // EXAMPLE: do something useful with the barcode data
    self.resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    self.resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}


#pragma mark - Private methods
- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [[[ZBarReaderViewController alloc] init] autorelease];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    // Present the controller
    [self presentModalViewController:reader animated:YES];
}


@end
