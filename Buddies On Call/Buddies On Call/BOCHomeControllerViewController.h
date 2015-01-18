//
//  BOCHomeControllerViewController.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BOCHTTPClient.h"
#import "BOCRefreshService.h"

@interface BOCHomeControllerViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocation *recentLocation;
    __block BOOL isSessionInProgress;
    __block BOOL sessionRequestInProgress;
    __block BOOL isLoggedIn;
    __block BOOL loginInProgress;
    
    int incomingLocationCounter;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) BOCHTTPClient *httpClient;
@property (nonatomic, strong) BOCRefreshService *sharedService;
@property (nonatomic, strong) IBOutlet UIButton *buddyUp;

-(void)sessionResolved;

@end
