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
#import "BOCButton.h"

@interface BOCMapViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet BOCButton *cancelSession;

@property (nonatomic, strong) CLLocation *initialUserLocation;

-(void)drawBuddies:(NSDictionary *)buddies withLocationData:(NSDictionary *)locations;

-(void)buddiedUp;

@end
