//
//  BOCHTTPClient.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface BOCHTTPClient : NSObject

@property (nonatomic, strong) NSURLSession *session;

+(BOCHTTPClient *)sharedClient;

//User Methods
-(void)getUserObjectWithCompletion:(void (^)(NSError *)) completion;

-(void)openSessionForUser:(NSString *)user location:(NSString *)locationID completion:(void (^)(NSError *)) completion;

-(void)postLocation:(CLLocation *)location forUser:(NSString *)user completion:(void (^)(NSError *, NSString *locationID))completion;

-(void)checkSessionStatusesWithCompletion:(void (^)(NSError *)) completion;

@end
