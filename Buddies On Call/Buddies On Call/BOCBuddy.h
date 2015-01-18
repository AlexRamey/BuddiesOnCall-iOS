//
//  BOCBuddy.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BOCBuddy : NSObject <MKAnnotation>

//Required property from MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

//Optional properties from MKAnnotation
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
