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
        [_locationManager requestAlwaysAuthorization];
        
        isSessionInProgress = NO;
        sessionRequestInProgress = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _buddyUp.backgroundColor = [UIColor UVABlue];
    [_buddyUp setTitleColor:[UIColor UVAWhite] forState:UIControlStateNormal];
    [_buddyUp setTitle:@"Buddy Up!" forState:UIControlStateNormal];
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
    if (isSessionInProgress == NO && sessionRequestInProgress == NO)
    {
        sessionRequestInProgress = YES;
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //[_activityIndicator stopAnimating];
    NSLog(@"DID UPDATE LOC");
    recentLocation = [locations objectAtIndex:([locations count]-1)];
    
    [_httpClient postLocation:recentLocation forUser:@"abr8xq" completion:^(NSError *error, NSString *locationID)
    {
        if (!error)
        {
            NSLog(@"Did Post Location");
            if (isSessionInProgress == NO && sessionRequestInProgress == YES)
            {
                [_httpClient openSessionForUser:@"abr8xq" location:locationID completion:^(NSError *error)
                 {
                     if (!error)
                     {
                         isSessionInProgress = YES;
                         NSLog(@"Session In Progress!");
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to start session, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         [alert show];
                     }
                     
                     sessionRequestInProgress = NO;
                 }];
            }
        }
    }];
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
        NSLog(@"Authorized when in use . . .");
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"Always Authorized");
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
