//
//  BOCUserAnnotationView.m
//  Buddies On Call
//
//  Created by Alex Ramey on 2/5/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCUserAnnotationView.h"

@implementation BOCUserAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
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
        [self setImage:[UIImage imageNamed:@"userMarker"]];
        
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

@end
