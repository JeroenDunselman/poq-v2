//
//  TAATagStore.h
//  ParseStarterProject
//
//  Created by Axel Roest on 05-05-14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#import "TAATag.h"
#import "TAASpot.h"

#import "TAASpotStore.h" //only to get to our beloved testVIPS

typedef void(^TAAAllTagsBlock)(NSArray *objects, NSError *error);

@interface TAATagStore : NSObject

+ (instancetype)sharedStore;

// return all currently known local tags, no server interaction
-(NSMutableArray *)tags;

// add tag to the store
- (void) addTag:(TAASpot *)newTag;

// blocking method which gets all tags from the server
-(NSArray *)getTags;

// non-blocking method which gets all tags from the server, the block returns with the updated array
-(void) getAllTagsWithBlock:(TAAAllTagsBlock)block;

// non-blocking method which gets all tags from the server within the region, the block returns with the updated array
-(void) getAllTagsInCircularRegion:(CLCircularRegion *)region withBlock:(TAAAllTagsBlock)block;

@end
