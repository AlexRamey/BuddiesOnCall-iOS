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
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        //custom initialization
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    
    return self;
}

-(void)openSessionForUser:(NSString *)user location:(NSString *)locationID completion:(void (^)(NSError *)) completion
{
    NSData *postData = [[NSString stringWithFormat:@"{\"userid\":\"%@\",\"buddyid\":\"NIL\",\"firstlocationid\":\"%@\"}", user, locationID] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://boffo-server.bitnamiapp.com:5000/sessions"]];
    request.HTTPBody = postData;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@", error);
            completion(error);
        }
        else
        {
            NSLog(@"Response: %@", response);
            completion(nil);
        }
    }];
    
    [task resume];
}

-(void)postLocation:(CLLocation *)location forUser:(NSString *)user completion:(void (^)(NSError *, NSString *))completion
{
    int time = (int)[[NSDate date] timeIntervalSince1970];
    
    NSString *latitude = [[NSNumber numberWithDouble:location.coordinate.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    
    NSData *postData = [[NSString stringWithFormat:@"{\"userid\":\"%@\",\"lat\":\"%@\",\"lng\":\"%@\", \"time\" : %d}", user, latitude, longitude, time] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://boffo-server.bitnamiapp.com:5000/locations"]];
    request.HTTPBody = postData;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@", error);
            completion(error, nil);
        }
        else
        {
            NSLog(@"Response: %@", response);
            completion(nil, @"TEST");
        }
    }];
  
    [task resume];
}

@end
