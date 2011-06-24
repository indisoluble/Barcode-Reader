//
//  BarcodeReaderClientXcode3AppDelegate.m
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 24/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import "BarcodeReaderClientXcode3AppDelegate.h"
#import "CaptureBarcodeViewController.h"
#import "ListCapturesViewController.h"



@interface BarcodeReaderClientXcode3AppDelegate ()

#pragma mark -
#pragma mark Properties
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UITabBarController *tabBarController;

@end



@implementation BarcodeReaderClientXcode3AppDelegate

#pragma mark -
#pragma mark Synthesized properties
@synthesize window;

@synthesize tabBarController = __tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Initialize tabBarController
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    
    // Tab to capture barcode
    UINavigationController *captureBarcodesNavController = [[[UINavigationController alloc] init] autorelease];
    CaptureBarcodeViewController *captureBarcodeViewController =
	[[[CaptureBarcodeViewController alloc] initWithNibName:@"CaptureBarcodeViewController"
													bundle:nil
									  managedObjectContext:self.managedObjectContext] autorelease];
    [captureBarcodesNavController pushViewController:captureBarcodeViewController animated:NO];
    
    // Tab to list barcodes
    UINavigationController *listBarcodesNavController = [[[UINavigationController alloc] init] autorelease];
    ListCapturesViewController *listCapturesViewController =
	[[[ListCapturesViewController alloc] initWithStyle:UITableViewStylePlain
							   andManagedObjectContext:self.managedObjectContext] autorelease];
    [listBarcodesNavController pushViewController:listCapturesViewController animated:NO];
    
    // Adds tabs to tabBarController
    NSArray *viewControllers = [NSArray arrayWithObjects: captureBarcodesNavController, listBarcodesNavController, nil];
    self.tabBarController.viewControllers = viewControllers;
    
    // Show tabs
    [self.window addSubview:self.tabBarController.view];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
    self.tabBarController = nil;
    
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];	
	
    [window release];
    [super dealloc];
}


#pragma mark -
#pragma mark Private methods
#pragma mark -
#pragma mark Application's documents directory
/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Core Data stack
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{	
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{	
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]
                                              stringByAppendingPathComponent: @"BarcodeReaderClientXcode3-Model.sqlite"]];
	
	NSError *error;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:storeUrl
                                                          options:nil
                                                            error:&error])
    {
        NSLog(@"Error while creating persistent store coordinator. No access to database");
    }    
	
    return __persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{	
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return __managedObjectContext;
}



@end
