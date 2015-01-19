//
//  BOCButton.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/19/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BOCButton : UIButton

@property (strong,nonatomic) CAGradientLayer *backgroundLayer, *highlightBackgroundLayer;
@property (strong,nonatomic) CALayer *innerGlow;

@end
