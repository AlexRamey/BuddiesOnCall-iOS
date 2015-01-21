//
//  BOCHomeControllerViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCHomeControllerViewController.h"
#import "BOCMapViewController.h"
#import "BOCBuddyMapViewController.h"
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
        
        sessionRequestInProgress = NO;
        buddySessionRequestInProgress = NO;
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
    
    [_buddyLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buddyLogin setTitle:@"Buddy Login" forState:UIControlStateNormal];
    [_buddyLogin setTitle:@"Sesion Active" forState:UIControlStateDisabled];
    _buddyLogin.enabled = YES;
    
    //Resolve Any Previously Initiated Sessions that are lingering . . .
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    if ([userID intValue] != -1) //old user . . .
    {
        //Don't let the app delete a session that gets started right after button press
        [[BOCHTTPClient sharedClient] resolveAllSessionsForUser:userID completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                _buddyUp.enabled = YES;
                [_buddyUp setTitle:@"Session Active" forState:UIControlStateDisabled];
            });
        }];
    }
    else //new user
    {
        _buddyUp.enabled = YES;
    }
}

-(void)loginWithCompletion:(void (^)(void))attemptStartSession
{
    void (^createUser)() = ^(){
        UIAlertView *credentials = [[UIAlertView alloc] initWithTitle:@"Provide Info" message:@"Optionally provide your Name and Computing ID" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Submit", nil];
        credentials.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [credentials textFieldAtIndex:0].placeholder = @"Name";
        [credentials textFieldAtIndex:1].placeholder = @"Computing ID";
        credentials.tag = 0;
        [credentials show];
    };
    
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    if ([userID intValue] == -1)
    {
        createUser();
    }
    else
    {
        [_httpClient verifyUserObjectID:userID completion:^(NSError *error)
         {
             if (error)
             {
                 createUser();
             }
             else
             {
                 attemptStartSession();
             }
         }];
    }
}

-(IBAction)buddyUp:(id)sender
{
    [self setButtonsEnabled:NO];
    
    void (^attemptStartSession)() = ^(){
        sessionRequestInProgress = YES;
        [_locationManager startUpdatingLocation];
    };
    
    [self loginWithCompletion:attemptStartSession];
    
}

-(void)sessionResolved
{
    if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [_locationManager stopUpdatingLocation];
    [self setButtonsEnabled:YES];
}

//BUDDY_CODE

-(IBAction)buddyLogin:(id)sender
{
    [self setButtonsEnabled:NO];
    
    //new user
    void (^createUser)() = ^(){
        UIAlertView *credentials = [[UIAlertView alloc] initWithTitle:@"Provide Info" message:@"Optionally provide your Name and Computing ID" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Submit", nil];
        credentials.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [credentials textFieldAtIndex:0].placeholder = @"Name";
        [credentials textFieldAtIndex:1].placeholder = @"Computing ID";
        credentials.tag = 1;
        [credentials show];
    };
    
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    if ([userID intValue] == -1)
    {
        createUser();
    }
    else
    {
        [_httpClient verifyUserObjectID:userID completion:^(NSError *error)
         {
             if (error)
             {
                 createUser();
             }
             else
             {
                 //now check to verify that user is buddy
                 [_httpClient verifyBuddyObjectID:userID completion:^(NSError *error, NSNumber *buddyID) {
                     if (error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Verified user object, but you're not a buddy!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                             [self setButtonsEnabled:YES];
                         });
                     }
                     else
                     {
                         [[NSUserDefaults standardUserDefaults] setObject:buddyID forKey:BOC_BUDDY_ID_KEY];
                         buddySessionRequestInProgress = YES;
                         [_locationManager startUpdatingLocation];
                     }
                 }];
                 
             }
         }];
    }
}

//END_BUDDY_CODE

-(void)setButtonsEnabled:(BOOL)enabled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _buddyUp.enabled = enabled;
        [_buddyUp setNeedsDisplay];
        _buddyLogin.enabled = enabled;
        [_buddyLogin setNeedsDisplay];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_locationManager stopUpdatingLocation]; //force quit scenario . . .
    [_locationManager setDelegate:nil];
    [[BOCRefreshService sharedService] setHomeController:nil];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        userName = [alertView textFieldAtIndex:0].text;
        compID = [alertView textFieldAtIndex:1].text;
    }
    
    if (alertView.tag == 0) //buddy up!
    {
        [_httpClient createUserObjectWithName:userName email:[NSString stringWithFormat:@"%@@virginia.edu", compID] completion:^(NSError *error, NSNumber *userID)
         {
             if (error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to create user object." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                     [self setButtonsEnabled:YES];
                 });
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:BOC_USER_ID_KEY];
                 sessionRequestInProgress = YES;
                 [_locationManager startUpdatingLocation];
             }
         }];
    }
    else //buddy login . . .
    {
        [_httpClient createUserObjectWithName:userName email:[NSString stringWithFormat:@"%@@virginia.edu", compID] completion:^(NSError *error, NSNumber *userID)
         {
             if (error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to create user object" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 });
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:BOC_USER_ID_KEY];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Created user, but you're not a buddy!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 });
             }
             [self setButtonsEnabled:YES];
         }];
    }
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    recentLocation = [locations objectAtIndex:([locations count]-1)];
    
    if (!sessionRequestInProgress && !buddySessionRequestInProgress && incomingLocationCounter++ % 10 != 0)
    {
        return;
    }
    
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_USER_ID_KEY];
    
    [_httpClient postLocation:recentLocation forUser:userID completion:^(NSError *error, NSNumber *locationID)
    {
        if (!error)
        {
            if (buddySessionRequestInProgress)
            {
                buddySessionRequestInProgress = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"HomeToBuddyMap" sender:self];
                });
            }
            
            if (sessionRequestInProgress)
            {
                sessionRequestInProgress = NO;
                
                [_httpClient openSessionForUser:userID location:[locationID stringValue] completion:^(NSError *error)
                 {
                     if (!error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self performSegueWithIdentifier:@"HomeToUserMap" sender:self];
                         });
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to start session, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                             [_locationManager stopUpdatingLocation];
                             [self setButtonsEnabled:YES];
                         });
                     }
                 }];
            }
        }
        else
        {
            //there's an error posting location
            if (sessionRequestInProgress || buddySessionRequestInProgress)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to post location. Try again to start session." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    [_locationManager stopUpdatingLocation];
                    sessionRequestInProgress = NO;
                    buddySessionRequestInProgress = NO;
                    [self setButtonsEnabled:YES];
                });
            }
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([[error domain] caseInsensitiveCompare:kCLErrorDomain] == NSOrderedSame && [error code] == kCLErrorDenied)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Denied." message:@"Enable Location Services for this app in your device settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if (sessionRequestInProgress || buddySessionRequestInProgress)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get location. Try again to start session." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                sessionRequestInProgress = NO;
                buddySessionRequestInProgress = NO;
                [self setButtonsEnabled:YES];
            });
        }
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
    else if ([[segue destinationViewController] class] == [BOCBuddyMapViewController class])
    {
        BOCBuddyMapViewController *vc = (BOCBuddyMapViewController *)[segue destinationViewController];
        
        [vc setInitialUserLocation:recentLocation];
        
        
    }
}

@end
