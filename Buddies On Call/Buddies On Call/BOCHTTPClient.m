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

-(void)createUserObjectWithName:(NSString *)name email:(NSString *)email completion:(void (^)(NSError *, NSNumber *))completion
{
    NSData *postData = [[NSString stringWithFormat:@"{\"name\":\"%@\", \"email\":\"%@\"}", name, email] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://boffo-server.bitnamiapp.com:5000/users"]];
    request.HTTPBody = postData;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error);
            completion(error, nil);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Create User JSON: %@", json);
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if (![json objectForKey:@"added"])
            {
                NSError *userNotAdded = [[NSError alloc] initWithDomain:@"USER_NOT_Added" code:500 userInfo:nil];
                completion(userNotAdded, nil);
            }
            else
            {
                NSNumber *userID = [json objectForKey:@"added"];
                completion(nil, userID);
            }
        }
        
    }];
    
    [task resume];
}

-(void)verifyUserObjectID:(NSNumber *)userID completion:(void (^)(NSError *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/users/%d", [userID intValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(error);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Verify User JSON: %@", json);
            if (parseError)
            {
                completion(parseError);
            }
            else if (![json objectForKey:@"id"])
            {
                NSError *userNotFound = [[NSError alloc] initWithDomain:@"USER_NOT_FOUND" code:500 userInfo:nil];
                completion(userNotFound);
            }
            else
            {
                completion(nil);
            }
        }
    }];
    
    [task resume];
}

-(void)openSessionForUser:(NSNumber *)userID location:(NSString *)locationID completion:(void (^)(NSError *, NSNumber *)) completion
{
    NSData *postData = [[NSString stringWithFormat:@"{\"userid\":\"%@\",\"status\":\"open\",\"firstlocationid\":\"%@\"}", [userID stringValue], locationID] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://boffo-server.bitnamiapp.com:5000/sessions"]];
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
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            
            NSLog(@"Create Session JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if (![json objectForKey:@"added"])
            {
                NSError *sessionNotAdded = [[NSError alloc] initWithDomain:@"SESSION_NOT_ADDED" code:500 userInfo:nil];
                completion(sessionNotAdded, nil);
            }
            else
            {
                completion(nil,[json objectForKey:@"added"]);
            }
        }
    }];
    
    [task resume];
}

-(void)postLocation:(CLLocation *)location forUser:(NSNumber *)userID completion:(void (^)(NSError *, NSNumber *))completion
{
    int time = (int)[[NSDate date] timeIntervalSince1970];
    
    NSString *latitude = [[NSNumber numberWithDouble:location.coordinate.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    
    NSData *postData = [[NSString stringWithFormat:@"{\"userid\":\"%@\",\"lat\":\"%@\",\"lng\":\"%@\", \"time\" : %d}", [userID stringValue], latitude, longitude, time] dataUsingEncoding:NSUTF8StringEncoding];
    
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
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            
            NSLog(@"Post Location JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if (![json objectForKey:@"added"])
            {
                NSError *locationNotAdded = [[NSError alloc] initWithDomain:@"LOCATION_NOT_ADDED" code:500 userInfo:nil];
                completion(locationNotAdded, nil);
            }
            else
            {
                completion(nil,[json objectForKey:@"added"]);
            }
        }
    }];
  
    [task resume];
}

-(void)fetchUnresolvedSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *, NSArray *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/users/%@/sessions", [userID stringValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(error, nil);
        }
        else
        {
            NSError *parseError = nil;
            
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Fetch Sessions JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else
            {
                completion(nil, json);
            }
        }
    }];
    
    [task resume];
}

-(void)fetchLastLocationForBuddy:(NSString *)buddyID completion:(void (^)(NSError *, NSDictionary *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/buddies/%@/lastlocation", buddyID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(error, nil);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Fetch Last Buddy Location JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else
            {
                completion(nil, json);
            }
        }
    }];
    
    [task resume];
}

@end
