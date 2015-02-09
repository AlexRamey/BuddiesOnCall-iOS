//
//  BOCUser.m
//  Buddies On Call
//
//  Created by Alex Ramey on 2/5/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCUser.h"

@implementation BOCUser

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)title subtitle:(NSString *)subtitle
{
    self = [super init];
    
    if (self)
    {
        _coordinate = coord;
        _title = title;
        _subtitle = subtitle;
    }
    
    return self;
}


@end
