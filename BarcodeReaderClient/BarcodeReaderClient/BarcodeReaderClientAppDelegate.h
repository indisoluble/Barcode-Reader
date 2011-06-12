//
//  BarcodeReaderClientAppDelegate.h
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@interface BarcodeReaderClientAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;

    UITabBarController *__tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
