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

@interface BOCHomeControllerViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocation *recentLocation;
    BOOL isSessionInProgress;
    BOOL sessionRequestInProgress;
    BOOL isLoggedIn;
    BOOL loginInProgress;
    
    int incomingLocationCounter;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) BOCHTTPClient *httpClient;

@property (nonatomic, strong) IBOutlet UIButton *buddyUp;

@end
