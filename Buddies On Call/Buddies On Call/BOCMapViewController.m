//
//  BOCMapViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCMapViewController.h"
#import "BOCHTTPClient.h"
#import "BOCRefreshService.h"
#import "BOCBuddyAnnotationView.h"
#import "BOCBuddy.h"
#import "AppDelegate.h"

@interface BOCMapViewController ()

@end

@implementation BOCMapViewController

static NSString * const reuseIdentifier = @"BUDDY_ANNOTATION_REUSE_IDENTIFIER";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom init
        [[BOCRefreshService sharedService] setMapController:self];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance([_initialUserLocation coordinate], 400, 400) animated:YES];
    [_mapView setShowsUserLocation:YES];
}

-(void)buddiedUp
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[BOCRefreshService sharedService] setMapController:nil];
}

-(void)drawBuddies:(NSDictionary *)buddies withLocationData:(NSDictionary *)locations
{
    NSLog(@"Draw Buddies");
    
    NSLog(@"Buddies: %@", buddies);
    
    NSLog(@"Location Data: %@", locations);
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
        BOCBuddyAnnotationView *pinView = (BOCBuddyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        
        if (!pinView)
        {
            pinView = [[BOCBuddyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        else
        {
            pinView = [pinView initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
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
