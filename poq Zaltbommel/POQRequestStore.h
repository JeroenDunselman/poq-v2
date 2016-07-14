//
//  POQRequestStore.h
//  
//
//  Created by Jeroen Dunselman on 05/11/15.
//
//

#import <Foundation/Foundation.h>
#import "POQRequest.h"
#import "POQPromo.h"
#import "POQActie.h"
#import "POQActie+Promo+Users.h"
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

-(NSArray *)getActies;
-(BOOL) getPromoActionableStatusWithId: (NSString *)PromoId;
-(NSArray *)getPromos; //from backend
-(NSArray *)localPromos; //available
-(NSArray *)getRqsts;
-(NSArray *)getUsers;
-(NSArray *) buurtSet;

-(NSArray *) getBuurtSet;
-(NSArray *) buurtSetLazy;
-(NSString *) adminIdRick;
@property (nonatomic, retain) NSMutableDictionary *avatars;
//@property (nonatomic, retain) NSArray *localPromos; //

// non-blocking method which gets all tags from the server, the block returns with the updated array
//-(void) getAllRqstsWithBlock:(POQAllRqstsBlock)block;
-(void) getPOQUserData;
-(void) getBuurtRequestsWithBlock:(POQBuurtRequestsBlock)block;
-(void) getBuurtUsersWithBlock:(POQBuurtUsersBlock)block;
//-(void) getBuurtSetWithBlock:(POQBuurtSetBlock)block;
-(PFUser *) getPFUserWithId: (NSString *)userId;
-(POQRequest *) getRequestWithUserId: (NSString *)userId createdAt:(NSDate *)date;
-(POQSettings *) getSettingsWithUserType: (NSString *)poqUserType;
-(BOOL) currentUserHasClaimedPromo:(NSString *)promoID;//theActie.actie.actiePromoID
-(BOOL) currentUserHasPromoted:(NSString *)promoID;
@end
