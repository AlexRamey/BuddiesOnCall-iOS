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

@interface BOCHomeControllerViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>
{
    CLLocation *recentLocation;
    __block BOOL sessionRequestInProgress;
    __block BOOL buddySessionRequestInProgress;
    int incomingLocationCounter;
    
    NSString *userName;
    NSString *compID;
    
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) BOCHTTPClient *httpClient;

@property (nonatomic, weak) IBOutlet UIButton *buddyUp;

//Buddy Code
@property (nonatomic, weak) IBOutlet UIButton *buddyLogin;

//End Buddy Code

-(void)sessionResolved;

@end
