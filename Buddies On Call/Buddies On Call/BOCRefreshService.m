//
//  BOCRefreshService.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCRefreshService.h"
#import "AppDelegate.h"
#import "BOCMapViewController.h"
#import "BOCHomeControllerViewController.h"

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
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
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
    
    [_httpClient fetchUnresolvedSessionsForUser:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY] completion:^(NSError *error, NSDictionary *sessions) {
        if (!error)
        {
            //check to see if any of the sessions have status "resolved"
            if([[sessions objectForKey:@"sessions"] count] == 0) //they have all been resolved!
            {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Session Resolved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        
                        if (_homeController)
                        {
                            [_homeController sessionResolved];
                        }
                    });
                    
                    inProgress = NO;
                    [self stop];
                    
                    return;
            }
            
            //check to see if any of the sessions have status "working"
            for (NSDictionary *session in [sessions objectForKey:@"sessions"])
            {
                if ([[session objectForKey:@"status"] caseInsensitiveCompare:@"working"] == NSOrderedSame )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_mapController)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your Buddy has Arrived!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                            [self.mapController dismissViewControllerAnimated:YES completion:nil];
                        }
                    });
                    
                    inProgress = NO;
                    return;
                }
            }
            
            NSMutableDictionary *enrouteBuddies = [[NSMutableDictionary alloc] init];
            //check to see if any of the sessions have status "enroute"
            for (NSDictionary *session in [sessions objectForKey:@"sessions"])
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
            
            if ([buddyIDs count] == 0)
            {
                inProgress = NO;
                return;
            }
            
            __block int completionCounter = 0;
            
            __block int locationDownloadCounter = (int)[buddyIDs count];
            
            __block int buddyInfoDownloadCounter = (int)[buddyIDs count];
            
            __block NSMutableDictionary *buddyLocations = [[NSMutableDictionary alloc] init];
            
            __block NSMutableDictionary *buddyInformation = [[NSMutableDictionary alloc] init];
            
            for (NSString *buddyID in buddyIDs)
            {
                [_httpClient fetchLastLocationForBuddy:buddyID completion:^(NSError *error, NSDictionary *location) {
                    if (!error)
                    {
                        [buddyLocations setObject:location forKey:buddyID];
                    }
                    if (--locationDownloadCounter == 0 && ++completionCounter == 2)
                    {
                        inProgress = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.mapController)
                            {
                                [self.mapController drawBuddies:buddyInformation withLocationData:buddyLocations];
                            }
                        });
                    }
                }];
            }
            
            for (NSString *buddyID in buddyIDs)
            {
                [_httpClient fetchInformationForBuddy:buddyID completion:^(NSError *error, NSDictionary *buddy) {
                    if (!error)
                    {
                        [buddyInformation setObject:buddy forKey:buddyID];
                    }
                    if (--buddyInfoDownloadCounter == 0 && ++completionCounter == 2)
                    {
                        inProgress = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.mapController)
                            {
                                [self.mapController drawBuddies:buddyInformation withLocationData:buddyLocations];
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
