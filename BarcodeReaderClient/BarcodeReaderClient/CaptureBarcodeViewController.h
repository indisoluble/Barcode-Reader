//
//  CaptureBarcodeViewController.h
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZBarSDK.h"



@interface CaptureBarcodeViewController : UIViewController <ZBarReaderDelegate> {
    UIImageView *__resultImage;
    UITextView *__resultText;
}

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;

@end
