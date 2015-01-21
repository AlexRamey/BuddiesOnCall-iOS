//
//  AppDelegate.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern NSString * const BOC_IS_FIRST_LAUNCH_KEY;

extern NSString * const BOC_USER_ID_KEY;

extern NSString * const BOC_BUDDY_ID_KEY;

extern NSString * const BOC_SESSION_ID_KEY;

@property (strong, nonatomic) UIWindow *window;


@end

