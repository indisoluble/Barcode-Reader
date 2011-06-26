//
//  CaptureModel.h
//  BarcodeReaderClientXcode3
//
//  Created by Enrique de la Torre on 26/06/11.
//  Copyright 2011 Enrique de la Torre. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface CaptureModel :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * price;

@end



