//
//  CaptureBarcodeViewController.h
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 24/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ZBarSDK.h"



@interface CaptureBarcodeViewController : UIViewController <ZBarReaderDelegate> {
    
    NSManagedObjectContext *__managedObjectContext;
    
    UIImageView *__resultImage;
    UITextView *__resultText;
}

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
 managedObjectContext:(NSManagedObjectContext *)moc;

- (IBAction)scanButtonTapped;

@end
