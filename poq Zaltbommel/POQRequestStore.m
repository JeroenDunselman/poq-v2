//
//  POQRequestStore.m
//  
//
//  Created by Jeroen Dunselman on 05/11/15.
//
//

#import "POQRequestStore.h"
#import "ParseFacebookUtilsV4/PFFacebookUtils.h"
#import "Parse/Parse.h"

@interface POQRequestStore ()
@property (nonatomic) NSMutableArray *rqstCollectionPrivate;
@property (nonatomic) NSMutableArray *userCollectionPrivate;
//@property (nonatomic) NSString *userId;

- (instancetype)initPrivate;

@end
@implementation POQRequestStore
+ (instancetype)sharedStore
{
    static POQRequestStore *rqstStore = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{                // thread safe singleton, chapter 17
        rqstStore = [[self alloc] initPrivate];
    });
    
    return rqstStore;
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
        self.rqstCollectionPrivate = [[NSMutableArray alloc] init];
    }
    return self;
}
-(NSMutableArray *)rqsts
{
    return self.rqstCollectionPrivate;
}

// not recommended, blocking main thread
// returns from cache, but does NOT refresh
-(NSArray *)getRqsts
{
//    if (!self.rqstCollectionPrivate) {
        NSString *rqstClass = [POQRequest parseClassName];
        // Retrieve all tags from Parse
        PFQuery *query = [PFQuery queryWithClassName:rqstClass];
//        query.cachePolicy = kPFCachePolicyNetworkElseCache; crash
    
//    PFQuery *query = [PFQuery queryWithClassName:self.className];
   
//    [query whereKey:@"de_guardia" equalTo:@"Si"];
    NSDate *now = [NSDate date];
    NSDateComponents *days = [NSDateComponents new];
    [days setDay:-1];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *oneDayAgo = [cal dateByAddingComponents:days toDate:now options:0];
    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    
    [query orderByDescending:@"createdAt"];
        NSArray *resultObjects = [query findObjects];
        self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
//    }
    // Return all tags
//    POQRequest rqst = self.rqstCollectionPrivate[0];
    return self.rqstCollectionPrivate;
}

// recommended getter, starts background task and calls the block when it's finished.
-(void) getAllRqstsWithBlock:(POQAllRqstsBlock)block
{
    // Clear private array
    // [self.tagCollectionPrivate removeAllObjects];
    
    NSString *rqstClass = [POQRequest parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:rqstClass];
    // query.cachePolicy = kPFCachePolicyNetworkElseCache;
    // Add every tag-object from query to 1 array filled with TAATag instances
    //[query whereKey:@"title" equalTo:@"Dan Stemkoski"];
    //    [query whereKey:@"spotTitle" containsString:@"Ander"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);
            // Do something with the found objects
            //            for (PFObject *object in objects) {
            //                POQRequest *aRqst = (POQRequest *)object;
            ////                NSLog(@"%@", aRqst);
            //            }
            // store in cache
            self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:objects];    // make mutable
            block(objects, error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

//**
-(void) getBuurtUsersWithBlock:(POQBuurtUsersBlock)block
{
    PFQuery *query = [PFUser query];
    query.limit = 100;
    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    static double distance = 5;
    [query whereKey:@"location" nearGeoPoint:myLocation withinMiles: distance];
    [query orderByAscending:@"geoPoint"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);
            // Do something with the found objects
//            for (PFObject *object in objects) {
//                POQRequest *aRqst = (POQRequest *)object;
////                NSLog(@"%@", aRqst);
//            }
            // store in cache
            self.userCollectionPrivate = [NSMutableArray arrayWithArray:objects];    // make mutable
            block(objects, error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
//**

@end
