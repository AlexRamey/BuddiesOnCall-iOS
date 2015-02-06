//
//  BOCBuddyRefreshService.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/23/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCBuddyRefreshService.h"
#import "AppDelegate.h"
#import "BOCHTTPClient.h"
#import "BOCBuddyMapViewController.h"
#import "BOCHomeControllerViewController.h"

@implementation BOCBuddyRefreshService

+(BOCBuddyRefreshService *)sharedService
{
    static BOCBuddyRefreshService *sharedService = nil;
    
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
    isOnCall = YES;
    isWorking = NO;
    
    _timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(updateBuddiesAndSessionsInformationForBuddy:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}

-(void)stop
{
    [_timer invalidate];
}

-(IBAction)updateBuddiesAndSessionsInformationForBuddy:(id)sender
{
    if (inProgress)
    {
        return;
    }
    
    inProgress = YES;
    
    [_httpClient fetchUnresolvedSessionsForBuddy:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] completion:^(NSError *error, NSDictionary *sessions)
    {
        if (!error)
        {
            NSArray *sessionList = [sessions objectForKey:@"sessions"];
            
            if ([sessionList count] > 0 && isOnCall)
            {
                //You have an assignment!
                isOnCall = NO;
                
                if (_mapController)
                {
                    [_mapController notifyBuddyOnCall];
                }
            }
            
            if ([sessionList count] == 0 && !isOnCall)
            {
                //Sessions got resolved for you somehow . . .
                [self stop];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_mapController)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"All your sessions are complete!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        [self.mapController dismissViewControllerAnimated:YES completion:nil];
                    }
                });
                
                inProgress = NO;
                return;
            }
            
            if ([sessionList count] > 0 && !isOnCall)
            {
                __block int taskCounter = 0;
                
                NSMutableDictionary *fellowBuddies = [[NSMutableDictionary alloc] init];
                NSString *userID = nil;
                
                //check to see if any of the sessions have status "enroute"
                for (NSDictionary *session in sessionList)
                {
                    if ([[session objectForKey:@"buddyid"] intValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] intValue])
                    {
                        [fellowBuddies setObject:session forKey:[[session objectForKey:@"buddyid"] stringValue]];
                    }
                    
                    if (!userID)
                    {
                        userID = [session objectForKey:@"userid"];
                    }
                    
                    if (!isWorking && [[session objectForKey:@"status"] caseInsensitiveCompare:@"working"] == NSOrderedSame)
                    {
                        isWorking = YES;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.mapController)
                            {
                                [self.mapController.actionButton setTitle:@"Update Status to Resolved" forState:UIControlStateNormal];
                            }
                        });
                    }
                }
                
                if (userID)
                {
                    taskCounter++;
                    
                    __block int userPacketCounter = 0;
                    __block NSError *err = nil;
                    __block NSDictionary *userInfo = nil;
                    __block NSDictionary *userLocation = nil;
                    
                    [_httpClient getUserInfo:[NSNumber numberWithInt:[userID intValue]] completion:^(NSDictionary *info, NSError *error) {
                        if (error)
                        {
                            err = error;
                        }
                        
                        userInfo = info;
                        
                        if (++userPacketCounter == 2)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.mapController)
                                {
                                    [self.mapController drawUser:userInfo withLocationData:userLocation];
                                }
                            });
                            
                            if (--taskCounter == 0)
                            {
                                inProgress = NO;
                            }
                        }
                    }];
                    
                    [_httpClient getLastLocationForUser:[NSNumber numberWithInt:[userID intValue]] completion:^(NSDictionary *info, NSError *error) {
                        if (error)
                        {
                            err = error;
                        }
                        
                        userLocation = info;
                        
                        if (++userPacketCounter == 2)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.mapController)
                                {
                                    [self.mapController drawUser:userInfo withLocationData:userLocation];
                                }
                            });
                            
                            if (--taskCounter == 0)
                            {
                                inProgress = NO;
                            }
                        }
                    }];
                }
                
                NSArray *buddyIDs = [fellowBuddies allKeys];
                
                taskCounter++;
                
                if ([buddyIDs count] == 0)
                {
                    if (--taskCounter == 0)
                    {
                        inProgress = NO;
                    }
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
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.mapController)
                                {
                                    [self.mapController drawBuddies:buddyInformation withLocationData:buddyLocations];
                                }
                            });
                            if (--taskCounter == 0)
                            {
                                inProgress = NO;
                            }
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
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.mapController)
                                {
                                    [self.mapController drawBuddies:buddyInformation withLocationData:buddyLocations];
                                }
                            });
                            if (--taskCounter == 0)
                            {
                                inProgress = NO;
                            }
                        }
                    }];
                }
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
