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
        
        isSessionInProgress = NO;
        sessionRequestInProgress = NO;
        isLoggedIn = NO;
        loginInProgress = NO;
        
        incomingLocationCounter = 0;
        
        userName = @"";
        compID = @"";
        
        buddySessionRequestInProgress = NO;
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
    [_locationManager stopUpdatingLocation]; //force quit scenario . . .
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
        if (isLoggedIn && !isSessionInProgress && !sessionRequestInProgress && !buddySessionRequestInProgress)
        {
            sessionRequestInProgress = YES;
            [_locationManager startUpdatingLocation];
        }
    };
    
    if (!isLoggedIn && !loginInProgress)
    {
        loginInProgress = YES;
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
    
    [_locationManager stopUpdatingLocation];
    
    isSessionInProgress = NO;
    _buddyUp.enabled = YES;
    _buddyLogin.enabled = YES;
}

//BUDDY_CODE

-(IBAction)buddyLogin:(id)sender
{
    if (loginInProgress || buddySessionRequestInProgress || sessionRequestInProgress) return;
    
    if (isLoggedIn)
    {
        buddySessionRequestInProgress = YES;
        [_locationManager startUpdatingLocation];
        return;
    }
    else
    {
        loginInProgress = YES;
    }
    
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
    else //verify that existing user is still good
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
                 
                 //now check to verify that user is buddy
                 [_httpClient verifyBuddyObjectID:userID completion:^(NSError *error, NSNumber *buddyID) {
                     if (error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Verified user object, but you're not a buddy!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                         });
                     }
                     else
                     {
                         //current stored userID is good
                         [[NSUserDefaults standardUserDefaults] setObject:buddyID forKey:BOC_BUDDY_ID_KEY];
                         buddySessionRequestInProgress = YES;
                         [_locationManager startUpdatingLocation];
                     }
                     isLoggedIn = YES;
                     loginInProgress = NO;
                 }];
                 
             }
         }];
    }
}

//END_BUDDY_CODE

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
        void (^attemptStartSession)() = ^(){
            if (isLoggedIn && !isSessionInProgress && !sessionRequestInProgress)
            {
                sessionRequestInProgress = YES;
                [_locationManager startUpdatingLocation];
            }
        };
        
        [_httpClient createUserObjectWithName:userName email:[NSString stringWithFormat:@"%@@virginia.edu", compID] completion:^(NSError *error, NSNumber *userID)
         {
             if (error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to create user object." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
                 isLoggedIn = YES;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Created user object, but you're not a buddy!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 });
             }
             
             loginInProgress = NO;
         }];
    }
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
            if (buddySessionRequestInProgress)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    buddySessionRequestInProgress = NO;
                    isSessionInProgress = YES;
                    [_buddyLogin setEnabled:NO];
                    [_buddyLogin setNeedsDisplay];
                    [_buddyUp setEnabled:NO];
                    [_buddyUp setNeedsDisplay];
                    [self performSegueWithIdentifier:@"HomeToBuddyMap" sender:self];
                });
                
            }
            
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
        else
        {
            //there's an error posting location
            if ((isSessionInProgress == NO && sessionRequestInProgress == YES) || buddySessionRequestInProgress)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to post location. Try again to start session." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    sessionRequestInProgress = NO;
                    buddySessionRequestInProgress = NO;
                });
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
    
    sessionRequestInProgress = NO;
    buddySessionRequestInProgress = NO;
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
