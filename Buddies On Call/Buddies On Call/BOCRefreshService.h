//
//  BOCRefreshService.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOCHTTPClient.h"

@class BOCMapViewController, BOCHomeControllerViewController;

@interface BOCRefreshService : NSObject
{
    __block BOOL inProgress;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BOCHTTPClient *httpClient;

@property (nonatomic, weak) BOCMapViewController *mapController;
@property (nonatomic, weak) BOCHomeControllerViewController *homeController;

+(BOCRefreshService *)sharedService;

-(void)start;

-(void)stop;

@end
