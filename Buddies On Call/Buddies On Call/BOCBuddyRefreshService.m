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
        
        isOnCall = YES;
    }
    
    return self;
}

-(void)start
{
    _timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(updateBuddiesAndSessionsInformationForBuddy:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}

-(void)stop
{
    [_timer invalidate];
    isOnCall = YES;
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
            
            if (isOnCall && [sessionList count] > 0)
            {
                isOnCall = NO;
                
                if (_mapController)
                {
                    [_mapController notifyBuddyOnCall];
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
