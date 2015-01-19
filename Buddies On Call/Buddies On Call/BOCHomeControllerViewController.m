//
//  BOCHomeControllerViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCHomeControllerViewController.h"
#import "BOCMapViewController.h"
#import "AppDelegate.h"
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
        
        [[BOCRefreshService sharedService] setHomeController:self];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setPausesLocationUpdatesAutomatically:YES];
        [_locationManager setActivityType:CLActivityTypeFitness];
        [_locationManager requestAlwaysAuthorization];
        
        isSessionInProgress = NO;
        sessionRequestInProgress = NO;
        isLoggedIn = NO;
        loginInProgress = NO;
        
        incomingLocationCounter = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_buddyUp setTitleColor:[UIColor UVAWhite] forState:UIControlStateNormal];
    [_buddyUp setTitle:@"Buddy Up!" forState:UIControlStateNormal];
    _buddyUp.enabled = NO;
    
    //Resolve Any Previously Initiated Sessions that are lingering . . .
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    if ([userID intValue] != 0)
    {
        //Don't let the app delete a session that gets started right after button press
        [[BOCHTTPClient sharedClient] resolveAllSessionsForUser:userID completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                _buddyUp.enabled = YES;
                [_buddyUp setTitle:@"Session Active" forState:UIControlStateDisabled];
            });
        }];
    }
}

-(void)loginWithCompletion:(void (^)(void))attemptStartSession
{
    loginInProgress = YES;
    
    void (^createUser)() = ^(){
        NSLog(@"Create User");
        [_httpClient createUserObjectWithName:@"iOS Test" email:@"" completion:^(NSError *error, NSNumber *userID)
         {
             if (error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch user object" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 });
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:BOC_USER_ID_KEY];
                 isLoggedIn = YES;
                 attemptStartSession();
             }
             
             loginInProgress = NO;
         }];
    };
    
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    if ([userID intValue] == -1) //create new user object
    {
        createUser();
    }
    else //verify that existing one is still good
    {
        [_httpClient verifyUserObjectID:userID completion:^(NSError *error)
         {
             if (error)
             {
                 //Failed to verify user, therefore create a new one . . .
                 NSLog(@"Failed to verify user");
                 createUser();
             }
             else
             {
                 //current stored userID is good
                 NSLog(@"User was verified");
                 loginInProgress = NO;
                 isLoggedIn = YES;
                 attemptStartSession();
             }
         }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_locationManager setDelegate:nil];
    [[BOCRefreshService sharedService] setHomeController:nil];
}

-(IBAction)buddyUp:(id)sender
{
    /*
    [_httpClient makeFakeSessionForUser:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY] location:@"370" completion:^(NSError *error, NSNumber *number) {
        if (!error)
        {
            NSLog(@"Fake Number: %d", [number intValue]);
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    */
    void (^attemptStartSession)() = ^(){
        if (isLoggedIn && !isSessionInProgress && !sessionRequestInProgress)
        {
            sessionRequestInProgress = YES;
            [_locationManager startUpdatingLocation];
        }
    };
    
    if (!isLoggedIn && !loginInProgress)
    {
        [self loginWithCompletion:attemptStartSession];
    }
    else
    {
        attemptStartSession();
    }
}

-(void)sessionResolved
{
    if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    isSessionInProgress = NO;
    _buddyUp.enabled = YES;
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    recentLocation = [locations objectAtIndex:([locations count]-1)];
    
    if (incomingLocationCounter++ % 10 != 0)
    {
        return;
    }
    
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    [_httpClient postLocation:recentLocation forUser:userID completion:^(NSError *error, NSNumber *locationID)
    {
        if (!error)
        {
            if (isSessionInProgress == NO && sessionRequestInProgress == YES)
            {
                sessionRequestInProgress = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    _buddyUp.enabled = NO;
                    [_buddyUp setNeedsDisplay];
                });
                
                [_httpClient openSessionForUser:userID location:[locationID stringValue] completion:^(NSError *error, NSNumber *sessionID)
                 {
                     if (!error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             isSessionInProgress = YES;
                             [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:BOC_SESSION_ID_KEY];
                             _buddyUp.enabled = NO;
                             [_buddyUp setNeedsDisplay];
                             [self performSegueWithIdentifier:@"HomeToUserMap" sender:self];
                         });
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to start session, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                             _buddyUp.enabled = YES;
                             [_buddyUp setNeedsDisplay];
                         });
                     }
                 }];
            }
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] class] == [BOCMapViewController class])
    {
        BOCMapViewController *vc = (BOCMapViewController *)[segue destinationViewController];
        
        [vc setInitialUserLocation:recentLocation];
        
        [[BOCRefreshService sharedService] start];
    }
}

@end
