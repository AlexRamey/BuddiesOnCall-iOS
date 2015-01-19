//
//  AppDelegate.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "AppDelegate.h"
#import "BOCHTTPClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString * const BOC_IS_FIRST_LAUNCH_KEY = @"BOC_IS_FIRST_LAUNCH_KEY";

NSString * const BOC_USER_ID_KEY = @"BOC_USER_ID_KEY";

NSString * const BOC_SESSION_ID_KEY = @"BOC_SESSION_ID_KEY";

+(void)initialize
{
    //Register Factory Defaults, which will be created and temporarily stored in the registration
    //domain of NSUserDefaults. In the application domain, if no value has been assigned yet to a
    //specified key, then the application will look in the registration domain. The application domain
    //persists, so once a value has been set, factory defaults will always be ignored
    
    NSDictionary *defaults = @{
                               BOC_IS_FIRST_LAUNCH_KEY : @YES,
                               BOC_USER_ID_KEY : [NSNumber numberWithInt:-1],
                               BOC_SESSION_ID_KEY : [NSNumber numberWithInt:-1]
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /*
     unreliable . . . if a user terminates the app, then their session may not get updated . . .
    NSLog(@"Application will terminate");
    
    NSNumber *sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:BOC_SESSION_ID_KEY];
    
    if ([sessionID intValue] != -1)
    {
        [[BOCHTTPClient sharedClient] markSessionResolved:sessionID];
        NSLog(@"Session %d told to resolve", [sessionID intValue]);
    }
    */
}

@end
