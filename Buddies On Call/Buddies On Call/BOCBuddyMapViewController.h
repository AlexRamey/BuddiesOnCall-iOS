//
//  BOCBuddyMapViewController.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/21/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BOCBuddyMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) CLLocation *initialUserLocation;

@end
