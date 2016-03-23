//
//  POQRequestStore.h
//  
//
//  Created by Jeroen Dunselman on 05/11/15.
//
//

#import <Foundation/Foundation.h>
#import "POQRequest.h"
#import "POQSettings.h"
#import "Parse/Parse.h"
//typedef void(^POQAllRqstsBlock)(NSArray *objects, NSError *error);
typedef void(^POQBuurtUsersBlock)(NSArray *objects, NSError *error);
typedef void(^POQBuurtRequestsBlock)(NSArray *objects, NSError *error);

//typedef void(^POQBuurtSetBlock)(NSArray *objects, NSError *error);
//typedef void(^POQRequestBlock)(NSArray *objects, NSError *error);

@interface POQRequestStore : NSObject //<NSURLSessionDownloadDelegate>
+ (instancetype)sharedStore;

// return all currently known local tags, no server interaction
-(NSMutableArray *)rqsts;

// add tag to the store
//- (void) addTag:(TAASpot *)newTag;

// blocking method which gets all tags from the server
-(NSArray *)getRqsts;
-(NSArray *)getUsers;
-(NSArray *) buurtSet;

-(NSArray *) getBuurtSet;
-(NSArray *) buurtSetLazy;
@property (nonatomic, retain) NSMutableDictionary *avatars;

// non-blocking method which gets all tags from the server, the block returns with the updated array
//-(void) getAllRqstsWithBlock:(POQAllRqstsBlock)block;

-(void) getBuurtRequestsWithBlock:(POQBuurtRequestsBlock)block;
-(void) getBuurtUsersWithBlock:(POQBuurtUsersBlock)block;
//-(void) getBuurtSetWithBlock:(POQBuurtSetBlock)block;

-(POQRequest *) getRequestWithUserId: (NSString *)userId createdAt:(NSDate *)date;
-(POQSettings *) getSettingsWithUserType: (NSString *)poqUserType;
@end
