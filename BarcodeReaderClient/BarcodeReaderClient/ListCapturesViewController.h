//
//  ListCapturesViewController.h
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ListCapturesViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

    NSManagedObjectContext *__managedObjectContext;
    NSFetchedResultsController *__captureList;
    
}

- (id)initWithStyle:(UITableViewStyle)style andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
