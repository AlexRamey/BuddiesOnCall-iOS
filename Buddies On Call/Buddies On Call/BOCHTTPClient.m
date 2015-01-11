//
//  BOCHTTPClient.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCHTTPClient.h"

@implementation BOCHTTPClient

+(BOCHTTPClient *)sharedClient
{
    static BOCHTTPClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://boffo-server.bitnamiapp.com:5000/"]];
    });
    
    return sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.requestSerializer = requestSerializer;
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

-(void)initiateBuddyRequestWithStartLocation:(CLLocation *)startLocation completion:(void (^)(NSError *))completion
{
    NSString *userID = @"abr8xq";
    
    NSString *latitude = [[NSNumber numberWithDouble:startLocation.coordinate.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:startLocation.coordinate.longitude] stringValue];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"userid",
                            latitude, @"lat",
                            longitude, @"lng",
                            nil];
    
    [self POST:@"/locations" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject)
        {
            NSLog(@"Response: %@", responseObject);
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       if (error)
       {
           NSLog(@"Error: %@", error);
           completion(error);
       }
    }];
}

@end
