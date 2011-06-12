//
//  BarcodeReaderClientAppDelegate.h
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface BarcodeReaderClientAppDelegate : NSObject <UIApplicationDelegate> {
    UITabBarController *__tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
