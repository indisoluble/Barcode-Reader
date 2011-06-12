//
//  CaptureModel.h
//  BarcodeReaderClient
//
//  Created by Enrique de la Torre on 12/06/11.
//  Copyright (c) 2011 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CaptureModel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSData * image;

@end
