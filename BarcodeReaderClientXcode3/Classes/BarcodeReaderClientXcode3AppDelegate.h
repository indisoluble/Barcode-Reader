//
//  BarcodeReaderClientXcode3AppDelegate.h
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 24/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@interface BarcodeReaderClientXcode3AppDelegate : NSObject <UIApplicationDelegate> {
	
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
	
	UITabBarController *__tabBarController;
	
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

