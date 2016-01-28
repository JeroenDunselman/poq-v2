//
//  TAATagStore.m
//  ParseStarterProject
//
//  Created by Axel Roest on 05-05-14.
//
//

#import "TAATagStore.h"

@interface TAATagStore ()
@property (nonatomic) NSMutableArray *tagCollectionPrivate;
@property (nonatomic) NSString *userId;

- (instancetype)initPrivate;

@end

@implementation TAATagStore

+ (instancetype)sharedStore
{
    static TAATagStore *tagStore = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{                // thread safe singleton, chapter 17
        tagStore = [[self alloc] initPrivate];
    });
    
    return tagStore;
}

// Throws a crash when you inadvertedly call init in your code
- (instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:nil userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self){
        self.tagCollectionPrivate = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSMutableArray *)tags
{
    return self.tagCollectionPrivate;
}

// discussion: should we sync immediately to the Parse server, or not?
- (void) addTag:(TAASpot *)newTag
{
    if (newTag) {
        [self.tagCollectionPrivate addObject:newTag];
        [newTag postTag];
    }
}

// not recommended, blocking main thread
// returns from cache, but does NOT refresh
-(NSArray *)getTags
{
    if (!self.tagCollectionPrivate) {
        NSString *tagClass = [TAASpot parseClassName];
        // Retrieve all tags from Parse
        PFQuery *query = [PFQuery queryWithClassName:tagClass];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;

        NSArray *resultObjects = [query findObjects];
        self.tagCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];    // make mutable;
    }
    // Return all tags
    return self.tagCollectionPrivate;
}

// recommended getter, starts background task and calls the block when it's finished.
-(void) getAllTagsWithBlock:(TAAAllTagsBlock)block
{
    // Clear private array
    // [self.tagCollectionPrivate removeAllObjects];
    
    NSString *tagClass = [TAASpot parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:tagClass];
    // query.cachePolicy = kPFCachePolicyNetworkElseCache;
    // Add every tag-object from query to 1 array filled with TAATag instances
    //[query whereKey:@"title" equalTo:@"Dan Stemkoski"];
    [query whereKey:@"spotTitle" containsString:@"Ander"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d objects.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                TAASpot *aTag = (TAASpot *)object;
                NSLog(@"%@", aTag);
            }
            // store in cache
            self.tagCollectionPrivate = [NSMutableArray arrayWithArray:objects];    // make mutable
            block(objects, error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) getAllTagsInCircularRegion:(CLCircularRegion *)region withBlock:(TAAAllTagsBlock)block;
{
#warning untested as yet!
    // Clear private array
    [self.tagCollectionPrivate removeAllObjects];
    
    NSString *tagClass = [TAASpot parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:tagClass];
    
    // calculate query parameters from region
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:region.center.latitude longitude:region.center.longitude];
    float kms = region.radius / 1000.0;         // convert to kms
    [query whereKey:@"spotLocation" nearGeoPoint:userGeoPoint withinKilometers:kms];
    
    // Add every tag-object from query to 1 array filled with TAATag instances
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %d objects.", objects.count);
//            // Do something with the found objects
//            for (PFObject *object in objects) {
//                TAATag *aTag = (TAATag *)object;
//                NSLog(@"%@", aTag);
//            }
            // store in cache
            self.tagCollectionPrivate = [NSMutableArray arrayWithArray:objects];    // make mutable
            block(objects, error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
