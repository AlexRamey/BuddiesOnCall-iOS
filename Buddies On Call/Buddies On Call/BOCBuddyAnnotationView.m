//
//  BOCBuddyAnnotationView.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/17/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCBuddyAnnotationView.h"
#import "BOCBuddy.h"

@implementation BOCBuddyAnnotationView
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/
-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        //custom initialization . . .
        [self setAnnotation:annotation];
        [self setCanShowCallout:YES];
        [self setImage:[UIImage imageNamed:@"buddyEnrouteMarker"]];
        
        /*
         BOCBuddy *buddy = (BOCBuddy *)annotation;
        //Left Thumbnail Accessory
        UIImageView *leftCalloutAccessoryThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,40.0,40.0)];
        [leftCalloutAccessoryThumbnail setContentMode:UIViewContentModeScaleAspectFill];
        [leftCalloutAccessoryThumbnail setImage:[UIImage imageWithData:[venue getThumbnailData]]];
        [self setLeftCalloutAccessoryView:leftCalloutAccessoryThumbnail];
        */
    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
