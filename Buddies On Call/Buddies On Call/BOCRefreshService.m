//
//  BOCRefreshService.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCRefreshService.h"
#import "AppDelegate.h"

@implementation BOCRefreshService

+(BOCRefreshService *)sharedService
{
    static BOCRefreshService *sharedService = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    
    return sharedService;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        //custom initialization
        _httpClient = [BOCHTTPClient sharedClient];
        
        inProgress = NO;
    }
    
    return self;
}

-(void)start
{
    _timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(updateBuddiesAndSessionsInformationForUser:) userInfo:nil repeats:YES];
    [_timer fire];
}

-(void)stop
{
    [_timer invalidate];
}

-(IBAction)updateBuddiesAndSessionsInformationForUser:(id)sender
{
    NSLog(@"update Fired");
    
    if (inProgress)
    {
        return;
    }
    
    inProgress = YES;
    
    [_httpClient fetchUnresolvedSessionsForUser:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY] completion:^(NSError *error, NSArray *sessions) {
        if (!error)
        {
            //check to see if any of the sessions have status "resolved"
            for (NSDictionary *session in sessions)
            {
                if ([[session objectForKey:@"status"] caseInsensitiveCompare:@"resolved"] == NSOrderedSame )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Session Resolved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    });
                    
                    if (_homeController)
                    {
                        [_homeController sessionResolved];
                    }
                    
                    inProgress = NO;
                    [self stop];
                    
                    return;
                }
            }
            
            //check to see if any of the sessions have status "working"
            for (NSDictionary *session in sessions)
            {
                if ([[session objectForKey:@"status"] caseInsensitiveCompare:@"working"] == NSOrderedSame )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your Buddy has Arrived!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        
                        if (_mapController)
                        {
                            [self.mapController.parentViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    });
                    
                    inProgress = NO;
                    return;
                }
            }
            
            NSMutableDictionary *enrouteBuddies = [[NSMutableDictionary alloc] init];
            //check to see if any of the sessions have status "enroute"
            for (NSDictionary *session in sessions)
            {
                if ([[session objectForKey:@"status"] caseInsensitiveCompare:@"enroute"] == NSOrderedSame )
                {
                    if ([[session objectForKey:@"buddyid"] intValue] != 0) //only get real buddies
                    {
                        [enrouteBuddies setObject:session forKey:[[session objectForKey:@"buddyid"] stringValue]];
                    }
                }
            }
            
            NSArray *buddyIDs = [enrouteBuddies allKeys];
            
            __block int downloadCounter = (int)[buddyIDs count];
            
            enrouteBuddies = [[NSMutableDictionary alloc] init];
            
            for (NSString *buddyID in buddyIDs)
            {
                [_httpClient fetchLastLocationForBuddy:buddyID completion:^(NSError *error, NSDictionary *location) {
                    if (!error)
                    {
                        [enrouteBuddies setObject:location forKey:buddyID];
                    }
                    if (--downloadCounter == 0)
                    {
                        inProgress = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.mapController)
                            {
                                [self.mapController drawBuddies:[NSDictionary dictionaryWithDictionary:enrouteBuddies]];
                            }
                        });
                    }
                }];
            }
            
            
        }
        else
        {
            NSLog(@"Error: %@", error);
            inProgress = NO;
        }
    }];
}

@end
