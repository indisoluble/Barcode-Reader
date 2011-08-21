//
//  DefineBarcodeViewController.h
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 08/08/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DefineBarcodeDelegate

- (void)useBarcodeWithDescription:(NSString *)desc price:(NSNumber *)price;
- (void)discardBarcode;

@end


@interface DefineBarcodeViewController : UIViewController <UITextFieldDelegate> {
	
	UITextField *__barcodeDescription;
	UITextField *__barcodePrice;
	
	NSString *__barcodeText;
	UIImage *__barcodeImage;
	
	id<DefineBarcodeDelegate> __delegate;
}

@property (nonatomic, retain) IBOutlet UITextField *barcodeDescription;
@property (nonatomic, retain) IBOutlet UITextField *barcodePrice;

@property (nonatomic, assign) id<DefineBarcodeDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
			  barcode:(NSString *)barcode
				image:(UIImage *)image;

- (IBAction)useData;

@end
