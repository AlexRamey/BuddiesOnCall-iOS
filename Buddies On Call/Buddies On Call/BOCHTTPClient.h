//
//  BOCHTTPClient.h
//  Buddies On Call
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 HooApps. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface BOCHTTPClient : NSObject

@property (nonatomic, strong) NSURLSession *session;

+(BOCHTTPClient *)sharedClient;

//User Methods
-(void)createUserObjectWithName:(NSString *)name email:(NSString *)email completion:(void (^)(NSError *, NSNumber *)) completion;

-(void)verifyUserObjectID:(NSNumber *)userID completion:(void (^)(NSError *))completion;

//TODO: Remove Method
-(void)makeFakeSessionForUser:(NSNumber *)userID location:(NSString *)locationID completion:(void (^)(NSError *, NSNumber *)) completion;

-(void)openSessionForUser:(NSNumber *)userID location:(NSString *)locationID completion:(void (^)(NSError *)) completion;

-(void)postLocation:(CLLocation *)location forUser:(NSNumber *)userID completion:(void (^)(NSError *, NSNumber *locationID))completion;

-(void)fetchUnresolvedSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *, NSDictionary *))completion;

-(void)fetchLastLocationForBuddy:(NSString *)buddyID completion:(void (^)(NSError *, NSDictionary *))completion;

-(void)fetchInformationForBuddy:(NSString *)buddyID completion:(void (^)(NSError *, NSDictionary *)) completion;

-(void)resolveAllSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *))completion;

-(void)markSessionResolved:(NSNumber *)session completion:(void (^)(NSError *))completion;

-(void)cancelAllSessionsForUser:(NSNumber *)userID completion:(void (^)(NSError *))completion;

-(void)markSessionCancelled:(NSNumber *)session completion:(void (^)(NSError *))completion;

//Buddy Methods
-(void)verifyBuddyObjectID:(NSNumber *)userID completion:(void (^)(NSError *, NSNumber *))completion;

-(void)setBuddyWithID:(NSNumber *)buddyID onCall:(BOOL)onCall completion:(void (^)(NSError *))completion;

-(void)fetchUnresolvedSessionsForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *, NSDictionary *))completion;

-(void)failAllSessionsForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *))completion;

-(void)setAllSessionsWorkingForBuddy:(NSNumber *)buddyID completion:(void (^)(NSError *))completion;

-(void)getUserInfo:(NSNumber *)userID completion:(void (^)(NSDictionary *info, NSError *))completion;

-(void)getLastLocationForUser:(NSNumber *)userID completion:(void (^)(NSDictionary *info, NSError *))completion;

@end
