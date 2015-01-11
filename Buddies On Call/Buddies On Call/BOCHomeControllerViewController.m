//
//  BOCHomeControllerViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCHomeControllerViewController.h"
#import "UIColor+Theme.h"

@interface BOCHomeControllerViewController ()

@end

@implementation BOCHomeControllerViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _httpClient = [BOCHTTPClient sharedClient];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager requestWhenInUseAuthorization];
        
        isSessionStart = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _buddyUp.backgroundColor = [UIColor UVABlue];
    [_buddyUp setTitleColor:[UIColor UVAWhite] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_locationManager setDelegate:nil];
}

-(IBAction)buddyUp:(id)sender
{
    _buddyUp.enabled = NO;
    
    if (isSessionStart == YES) //start session
    {
        [_locationManager startUpdatingLocation];
    }
    else //cancel session
    {
        NSLog(@"Cancel Session");
    }
    
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //[_activityIndicator stopAnimating];
    [_locationManager stopUpdatingLocation];
    
    if (isSessionStart)
    {
        //Start the Session
        startLocation = [locations objectAtIndex:([locations count]-1)];
        
        [_httpClient initiateBuddyRequestWithStartLocation:startLocation completion:^(NSError *error) {
            if (!error)
            {
                [_buddyUp setTitle:@"Cancel Request" forState:UIControlStateNormal];
                isSessionStart = NO;
                _buddyUp.enabled = YES;
            }
        }];
    }
    else
    {
        //handle location update
    }
    
    NSLog(@"Success: %@", startLocation);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //[_activityIndicator stopAnimating];
    NSLog(@"ERROR: %@", error);
    if ([[error domain] caseInsensitiveCompare:kCLErrorDomain] == NSOrderedSame)
    {
        if ([error code] == kCLErrorDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Denied." message:@"Enable Location Services for this app in your device settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    
    if (isSessionStart)
    {
        startLocation = nil;
        _buddyUp.enabled = YES;
    }
    
    [_locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Denied");
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //[_activityIndicator startAnimating];
        NSLog(@"Authorized");
    }
    else
    {
        //do nothing
        NSLog(@"Status %d", status);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
