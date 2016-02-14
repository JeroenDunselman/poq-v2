//
//  POQRequestStore.h
//  
//
//  Created by Jeroen Dunselman on 05/11/15.
//
//

#import <Foundation/Foundation.h>
#import "POQRequest.h"
#import "Parse/Parse.h"
typedef void(^POQAllRqstsBlock)(NSArray *objects, NSError *error);
typedef void(^POQBuurtUsersBlock)(NSArray *objects, NSError *error);

@interface POQRequestStore : NSObject
+ (instancetype)sharedStore;

// return all currently known local tags, no server interaction
-(NSMutableArray *)rqsts;

// add tag to the store
//- (void) addTag:(TAASpot *)newTag;

// blocking method which gets all tags from the server
-(NSArray *)getRqsts;

// non-blocking method which gets all tags from the server, the block returns with the updated array
-(void) getAllRqstsWithBlock:(POQAllRqstsBlock)block;

-(void) getBuurtUsersWithBlock:(POQBuurtUsersBlock)block;

@end
