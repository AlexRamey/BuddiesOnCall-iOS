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
#import "BOCMapViewController.h"
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
}

-(IBAction)updateBuddiesAndSessionsInformationForBuddy:(id)sender
{
    
}

@end
