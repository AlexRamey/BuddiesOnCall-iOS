//
//  BOCBuddyRefreshService.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/23/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BOCBuddyMapViewController, BOCHomeControllerViewController, BOCHTTPClient;

@interface BOCBuddyRefreshService : NSObject
{
    __block BOOL inProgress;
    __block BOOL isOnCall;
    __block BOOL isWorking;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BOCHTTPClient *httpClient;

@property (nonatomic, weak) BOCBuddyMapViewController *mapController;
@property (nonatomic, weak) BOCHomeControllerViewController *homeController;

+(BOCBuddyRefreshService *)sharedService;

-(void)start;

-(void)stop;

@end
