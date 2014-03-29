//
//  @(#)TTAPIGeocodeOperation.h 10/05/27
//  
//  MobileSDK
//
//  Copyright (c) 2010 TomTom International B.V. All rights reserved. TomTom
//  PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
//

#import <Foundation/Foundation.h>
#import "TTAPIOperation.h"
#import "TTSDKExceptions.h"

@class TTAPIGeocodeData;

/**
 * The geocode operation.
 * The operation calls the LBS service in order to make a geocode search.
 */
@interface TTAPIGeocodeOperation : TTAPIOperation {

}

/**
 * Returns the same as the super -(NSObject *)data method.
 * This is basically a helper method to avoid doing casts.
 * @return The parsed data.
 */
- (TTAPIGeocodeData *) data;

@end
