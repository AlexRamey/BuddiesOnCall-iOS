//
//  BOCBuddyMapViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/21/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCBuddyMapViewController.h"
#import "BOCBuddyRefreshService.h"
#import "BOCHomeControllerViewController.h"
#import "BOCHTTPClient.h"
#import "AppDelegate.h"
#import "BOCBuddy.h"
#import "BOCBuddyAnnotationView.h"
#import "BOCUserAnnotationView.h"
#import "BOCUser.h"

@interface BOCBuddyMapViewController ()

@end

@implementation BOCBuddyMapViewController

static NSString * const buddyReuseIdentifier = @"BUDDY_ANNOTATION_REUSE_IDENTIFIER";
static NSString * const userReuseIdentifier = @"USER_ANNOTATION_REUSE_IDENTIFIER";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        [[BOCBuddyRefreshService sharedService] setMapController:self];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"You are on call!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionButtonPressed:(id)sender
{
    NSString *status = [(UIButton *)sender titleForState:UIControlStateNormal];
    
    if ([status caseInsensitiveCompare:@"Update Status to Working"] == NSOrderedSame)
    {
        [[BOCHTTPClient sharedClient] setAllSessionsWorkingForBuddy:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] completion:^(NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_actionButton setTitle:@"Update Status to Resolved" forState:UIControlStateNormal];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to take mark all sessions working! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
            }
            
        }];
    }
    else if ([status caseInsensitiveCompare:@"Update Status to Resolved"] == NSOrderedSame)
    {
        [[BOCHTTPClient sharedClient] setAllSessionsWorkingForBuddy:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] completion:^(NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[BOCBuddyRefreshService sharedService] stop];
                    [(BOCHomeControllerViewController *)self.presentingViewController sessionResolved];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Mission Complete. Good work." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to take mark all sessions resolved! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
            }
            
        }];
    }
}

-(IBAction)missionFailedButtonPressed:(id)sender
{
    //Mark Session Failed
    [[BOCHTTPClient sharedClient] failAllSessionsForBuddy:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] completion:^(NSError *failError) {
        if (!failError)
        {
            //Take Buddy Off Call
            [[BOCHTTPClient sharedClient] setBuddyWithID:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] onCall:NO completion:^(NSError *error) {
                if (!error)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BOCBuddyRefreshService sharedService] stop];
                        [(BOCHomeControllerViewController *)self.presentingViewController sessionResolved];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to take you off call! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    });
                }
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to mark your session as failed. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
    }];
}

-(void)dealloc
{
    [[BOCBuddyRefreshService sharedService] setMapController:nil];
}

-(void)notifyBuddyOnCall
{
    //Web-Side will take set buddy to Off Call . . .
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"You have an assignment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    });
}

-(void)drawBuddies:(NSDictionary *)buddies withLocationData:(NSDictionary *)locations
{
    NSLog(@"Draw Buddies");
    
    NSLog(@"Buddies: %@", buddies);
    
    NSLog(@"Location Data: %@", locations);
    
    NSArray *keySet = [buddies allKeys];
    NSMutableArray *buddyAnnotations = [[NSMutableArray alloc] init];
    
    for (NSString *buddyID in keySet)
    {
        if (locations[buddyID])
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([locations[buddyID][@"locations"][@"lat"] doubleValue], [locations[buddyID][@"locations"][@"lng"] doubleValue]);
            NSString *subtitle = [@"Phone: " stringByAppendingString:buddies[buddyID][@"phone"]];
            NSString *title = buddies[buddyID][@"name"];
            BOCBuddy *buddy = [[BOCBuddy alloc] initWithCoordinate:coord title:title subtitle:subtitle];
            [buddyAnnotations addObject:buddy];
        }
    }
    
    //Remove old annotations
    for (BOCBuddy *annotation in _mapView.annotations)
    {
        [_mapView removeAnnotation:annotation];
    }
    
    [_mapView addAnnotations:buddyAnnotations];
    NSLog(@"Annotations Added!");
}

-(void)drawUser:(NSDictionary *)userInfo withLocationData:(NSDictionary *)location
{
    if (!userInfo || !location)
    {
        return;
    }
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([location[@"locations"][@"lat"] doubleValue], [location[@"locations"][@"lng"] doubleValue]);
    NSString *subtitle = [@"Phone: " stringByAppendingString:userInfo[@"phone"]];
    NSString *title = userInfo[@"name"];
    BOCUser *user = [[BOCUser alloc] initWithCoordinate:coord title:title subtitle:subtitle];
    
    for (BOCUser *annotation in _mapView.annotations)
    {
        [_mapView removeAnnotation:annotation];
    }
    
    [_mapView addAnnotation:user];
}

#pragma mark - MKMapViewDelegate Methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation isKindOfClass:[BOCBuddy class]])
    {
        //Try to dequeue an existing pin first
        BOCBuddyAnnotationView *pinView = (BOCBuddyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:buddyReuseIdentifier];
        
        if (!pinView)
        {
            pinView = [[BOCBuddyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:buddyReuseIdentifier];
        }
        else
        {
            pinView = [pinView initWithAnnotation:annotation reuseIdentifier:buddyReuseIdentifier];
        }
        return pinView;
    }
    
    if ([annotation isKindOfClass:[BOCUser class]])
    {
        //Try to dequeue an existing pin first
        BOCUserAnnotationView *pinView = (BOCUserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:userReuseIdentifier];
        
        if (!pinView)
        {
            pinView = [[BOCUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userReuseIdentifier];
        }
        else
        {
            pinView = [pinView initWithAnnotation:annotation reuseIdentifier:userReuseIdentifier];
        }
        
        return pinView;
    }
    
    
    return nil;
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
