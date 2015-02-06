//
//  BOCBuddyMapViewController.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/21/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BOCButton.h"

@interface BOCBuddyMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet BOCButton *actionButton;
@property (nonatomic, weak) IBOutlet BOCButton *missionFailed;
@property (nonatomic, strong) CLLocation *initialUserLocation;

-(void)drawBuddies:(NSDictionary *)buddies withLocationData:(NSDictionary *)locations;

-(void)drawUser:(NSDictionary *)userInfo withLocationData:(NSDictionary *)location;

-(void)notifyBuddyOnCall;

@end
