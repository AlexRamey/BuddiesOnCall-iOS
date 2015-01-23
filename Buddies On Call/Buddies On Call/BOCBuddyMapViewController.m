//
//  BOCBuddyMapViewController.m
//  Buddies On Call
//
//  Created by Alex Ramey on 1/21/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import "BOCBuddyMapViewController.h"
#import "BOCBuddyRefreshService.h"
#import "BOCHTTPClient.h"
#import "AppDelegate.h"

@interface BOCBuddyMapViewController ()

@end

@implementation BOCBuddyMapViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        [[BOCBuddyRefreshService sharedService] setMapController:self];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"You are on call!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionButtonPressed:(id)sender
{
    //update session . . .
}

-(IBAction)missionFailedButtonPressed:(id)sender
{
    //Mark Session Failed
    
    //Take Buddy Off Call
    [[BOCHTTPClient sharedClient] setBuddyWithID:[[NSUserDefaults standardUserDefaults] objectForKey:BOC_BUDDY_ID_KEY] onCall:NO completion:^(NSError *error) {
        if (!error)
        {
            //END Service --> which should pop this view controller . . .
            NSLog(@"Taken Off Call");
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to take you off call! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
    }];
}

-(void)dealloc
{
    [[BOCBuddyRefreshService sharedService] setMapController:nil];
}

-(void)notifyBuddyOnCall
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"You have an assignment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    });
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
