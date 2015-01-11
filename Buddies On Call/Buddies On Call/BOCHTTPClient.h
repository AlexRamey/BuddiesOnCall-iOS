//
//  BOCHTTPClient.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface BOCHTTPClient : AFHTTPSessionManager

+(BOCHTTPClient *)sharedClient;

-(void)initiateBuddyRequestWithStartLocation:(CLLocation *)startLocation completion:(void (^)(NSError *))completion;

@end
