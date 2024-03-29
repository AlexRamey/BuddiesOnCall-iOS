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

-(void)makeFakeSessionForUser:(NSNumber *)userID location:(NSString *)locationID completion:(void (^)(NSError *, NSNumber *)) completion
{
    NSData *postData = [[NSString stringWithFormat:@"{\"userid\":\"%@\",\"status\":\"enroute\",\"firstlocationid\":\"%@\",\"buddyid\":\"1\" }", [userID stringValue], locationID] dataUsingEncoding:NSUTF8StringEncoding];
    
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
            
            NSLog(@"Create Fake Session JSON: %@", json);
            
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

-(void)openSessionForUser:(NSNumber *)userID location:(NSString *)locationID completion:(void (^)(NSError *)) completion
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
            completion(error);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            
            NSLog(@"Create Session JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if (![json objectForKey:@"added"])
            {
                NSError *sessionNotAdded = [[NSError alloc] initWithDomain:@"SESSION_NOT_ADDED" code:500 userInfo:nil];
                completion(sessionNotAdded);
            }
            else
            {
                completion(nil);
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

-(void)fetchUnresolvedSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *, NSDictionary *))completion
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
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Fetch Sessions JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error, nil);
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
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error, nil);
            }
            else
            {
                completion(nil, json);
            }
        }
    }];
    
    [task resume];
}

-(void)fetchInformationForBuddy:(NSString *)buddyID completion:(void (^)(NSError *, NSDictionary *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/buddies/%@", buddyID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
            NSLog(@"Fetch Buddy Info JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error, nil);
            }
            else
            {
                completion(nil, json);
            }
        }
    }];
    
    [task resume];
}

-(void)resolveAllSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *))completion
{
    __block NSError *sessionResolutionError = nil;
    
    [self fetchUnresolvedSessionsForUser:userID completion:^(NSError *error, NSDictionary *sessions) {
        if (!error)
        {
            __block int counter = (int)[[sessions objectForKey:@"sesions"] count];
            
            for (NSDictionary *session in [sessions objectForKey:@"sessions"])
            {
                [self markSessionResolved:[session objectForKey:@"id"] completion:^(NSError * err){
                    if (!sessionResolutionError && err)
                    {
                        sessionResolutionError = err;
                    }
                    
                    if (--counter == 0)
                    {
                        completion(sessionResolutionError);
                    }
                }];
            }
            
            if (counter == 0)
            {
                completion(nil);
            }
        }
        else
        {
            completion(error);
        }
    }];
}

-(void)markSessionResolved:(NSNumber *)session completion:(void (^)(NSError *))completion
{
    NSData *putData = [@"{\"status\":\"resolved\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/sessions/%d", [session intValue]]]];
    request.HTTPBody = putData;
    request.HTTPMethod = @"PUT";
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
            NSLog(@"PUT Session Resolved JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error);
            }
            else
            {
                completion(nil);
            }
        }
    }];
    
    [task resume];
}

-(void)cancelAllSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *))completion
{
    __block NSError *sessionCancelError = nil;
    
    [self fetchUnresolvedSessionsForUser:userID completion:^(NSError *error, NSDictionary *sessions) {
        if (!error)
        {
            __block int counter = (int)[[sessions objectForKey:@"sesions"] count];
            
            for (NSDictionary *session in [sessions objectForKey:@"sessions"])
            {
                [self markSessionCancelled:[session objectForKey:@"id"] completion:^(NSError * err){
                    if (!sessionCancelError && err)
                    {
                        sessionCancelError = err;
                    }
                    
                    if (--counter == 0)
                    {
                        completion(sessionCancelError);
                    }
                }];
            }
            
            if (counter == 0)
            {
                completion(nil);
            }
        }
        else
        {
            completion(error);
        }
    }];
}

-(void)markSessionCancelled:(NSNumber *)session completion:(void (^)(NSError *))completion
{
    NSData *putData = [@"{\"status\":\"cancelled\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/sessions/%d", [session intValue]]]];
    request.HTTPBody = putData;
    request.HTTPMethod = @"PUT";
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
            NSLog(@"PUT Session Cancelled JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error);
            }
            else
            {
                completion(nil);
            }
        }
    }];
    
    [task resume];
}

-(void)markSessionFailed:(NSNumber *)session completion:(void (^)(NSError *))completion
{
    NSData *putData = [@"{\"status\":\"failed\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/sessions/%d", [session intValue]]]];
    request.HTTPBody = putData;
    request.HTTPMethod = @"PUT";
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
            NSLog(@"PUT Session Failed JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error);
            }
            else
            {
                completion(nil);
            }
        }
    }];
    
    [task resume];
}

-(void)markSessionWorking:(NSNumber *)session completion:(void (^)(NSError *))completion
{
    NSData *putData = [@"{\"status\":\"working\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/sessions/%d", [session intValue]]]];
    request.HTTPBody = putData;
    request.HTTPMethod = @"PUT";
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
            NSLog(@"PUT Session Working JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error);
            }
            else
            {
                completion(nil);
            }
        }
    }];
    
    [task resume];
}

-(void)verifyBuddyObjectID:(NSNumber *)userID completion:(void (^)(NSError *, NSNumber *))completion
{
    NSString *url = [@"http://boffo-server.bitnamiapp.com:5000/buddies" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            NSLog(@"Buddies JSON: %@", json);
            if (parseError)
            {
                completion(parseError, nil);
            }
            else
            {
                NSError *buddyNotFound = [[NSError alloc] initWithDomain:@"USER_NOT_FOUND" code:500 userInfo:nil];
                
                if ([[json objectForKey:@"status"] intValue] == 500)
                {
                    completion(buddyNotFound, nil);
                }
                else
                {
                    NSArray *buddies = [json objectForKey:@"buddies"];
                    for (NSDictionary *buddy in buddies)
                    {
                        if ([[buddy objectForKey:@"userid"] intValue] == [userID intValue])
                        {
                            //found!!!
                            
                            completion(nil, [buddy objectForKey:@"id"]);
                            return;
                        }
                    }
                    completion(buddyNotFound, nil);
                }
            }
            
        }
    }];
    
    [task resume];
}

-(void)setBuddyWithID:(NSNumber *)buddyID onCall:(BOOL)onCall completion:(void (^)(NSError *))completion
{
    int onCallValue = 0;
    
    if (onCall)
    {
        onCallValue = 1;
    }
    
    NSData *putData = [[NSString stringWithFormat:@"{\"oncall\":\"%d\"}", onCallValue] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/buddies/%d", [buddyID intValue]]]];
    request.HTTPBody = putData;
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(error);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"PUT BUDDY JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error);
            }
            else
            {
                completion(nil);
            }
        }
        
    }];
    
    [task resume];
}

-(void)fetchUnresolvedSessionsForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *, NSDictionary *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/buddies/%d/sessions", [buddyID intValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
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
            NSLog(@"Fetch Buddy Sessions JSON: %@", json);
            
            if (parseError)
            {
                completion(parseError, nil);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(error, nil);
            }
            else
            {
                completion(nil, json);
            }
        }
    }];
    
    [task resume];
}

-(void)failAllSessionsForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *))completion
{
    __block NSError *sessionFailError = nil;
    
    [self fetchUnresolvedSessionsForBuddy:buddyID completion:^(NSError *error, NSDictionary *sessions) {
        if (error)
        {
            completion(error);
        }
        else
        {
            NSArray *sessionList = [sessions objectForKey:@"sessions"];
            
            __block int counter = (int)[sessionList count];
            
            for (NSDictionary *session in sessionList)
            {
                [self markSessionFailed:[session objectForKey:@"id"] completion:^(NSError * err){
                    if (!sessionFailError && err)
                    {
                        sessionFailError = err;
                    }
                    
                    if (--counter == 0)
                    {
                        completion(sessionFailError);
                    }
                }];
            }
            
            
            if (counter == 0)
            {
                completion(nil);
            }
        }
    }];
}

-(void)setAllSessionsWorkingForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *))completion
{
    __block NSError *sessionWorkingError = nil;
    
    [self fetchUnresolvedSessionsForBuddy:buddyID completion:^(NSError *error, NSDictionary *sessions) {
        if (error)
        {
            completion(error);
        }
        else
        {
            NSArray *sessionList = [sessions objectForKey:@"sessions"];
            
            __block int counter = (int)[sessionList count];
            
            for (NSDictionary *session in sessionList)
            {
                [self markSessionWorking:[session objectForKey:@"id"] completion:^(NSError * err){
                    if (!sessionWorkingError && err)
                    {
                        sessionWorkingError = err;
                    }
                    
                    if (--counter == 0)
                    {
                        completion(sessionWorkingError);
                    }
                }];
            }
            
            if (counter == 0)
            {
                completion(nil);
            }
        }
    }];
}

-(void)getUserInfo:(NSNumber *)userID completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/users/%@/lastlocation", userID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(nil, error);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Fetch Last User Location JSON: %@", json);
            
            if (parseError)
            {
                completion(nil, parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(nil, error);
            }
            else
            {
                completion(json, nil);
            }
        }
    }];
    
    [task resume];
}

-(void)getLastLocationForUser:(NSNumber *)userID completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *url = [[NSString stringWithFormat:@"http://boffo-server.bitnamiapp.com:5000/users/%@", userID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) //either request went wrong or there isn't a user with this id
        {
            NSLog(@"Error: %@", error);
            completion(nil, error);
        }
        else
        {
            NSError *parseError = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"Fetch Last User Location JSON: %@", json);
            
            if (parseError)
            {
                completion(nil, parseError);
            }
            else if ([[json objectForKey:@"status"] intValue] == 500)
            {
                NSError *error = [[NSError alloc] init];
                completion(nil, error);
            }
            else
            {
                completion(json, nil);
            }
        }
    }];
    
    [task resume];
}

@end
