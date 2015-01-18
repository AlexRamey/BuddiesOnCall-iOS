//
//  BOCMapViewController.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BOCHTTPClient.h"

@interface BOCMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocation *initialUserLocation;

-(void)drawBuddies:(NSDictionary *)buddies withLocationData:(NSDictionary *)locations;

-(void)buddiedUp;

@end
