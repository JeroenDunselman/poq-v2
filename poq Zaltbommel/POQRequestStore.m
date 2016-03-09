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
#import "POQSettings.h"
@interface POQRequestStore ()
//**
@property (nonatomic) NSArray *rqstCollectionPrivate;
@property (nonatomic) NSArray *userCollectionPrivate;
//**
@property (nonatomic) NSArray *buurtAnnoSetPrivate;
//@property (nonatomic) NSString *userId;

- (instancetype)initPrivate;

@end
@implementation POQRequestStore

POQSettings *settings;
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
        self.userCollectionPrivate = [[NSMutableArray alloc] init];
    }
    return self;
}
-(NSMutableArray *)rqsts
{
    return [self.rqstCollectionPrivate copy];
}
-(NSMutableArray *)users
{
    return [self.userCollectionPrivate copy];
}


//** in gebruik
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
//    int numDays = 15;
//    NSDateComponents *days = [NSDateComponents new];
//    [days setDay:-numDays];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *daysAgo = [cal dateByAddingComponents:days toDate:now options:0];
//    [query whereKey:@"createdAt" greaterThan:daysAgo];
    NSString *strHrs = [settings objectForKey:@"urenAanbodGeldig"];
    int numHrs = [strHrs intValue];
//    NSString *string = @"5";
//    int value = [string intValue];
    
    NSDateComponents *hrs = [NSDateComponents new];
    [hrs setHour:-numHrs];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *hrsAgo = [cal dateByAddingComponents:hrs toDate:now options:0];
    [query whereKey:@"createdAt" greaterThan:hrsAgo];
    
    [query orderByDescending:@"createdAt"];
    NSArray *resultObjects = [query findObjects];
    self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
    //    }
    // Return all tags
    //    POQRequest rqst = self.rqstCollectionPrivate[0];
    return self.rqstCollectionPrivate;
}


-(NSArray *)getUsers {
    //    if (!self.rqstCollectionPrivate) {
    NSString *userClass = [PFUser parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:userClass];
    query.limit = 100;
    //    NSDate *now = [NSDate date];
    //    NSDateComponents *days = [NSDateComponents new];
    //    [days setDay:-1];
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    //    NSDate *oneDayAgo = [cal dateByAddingComponents:days toDate:now options:0];
    //    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    //
    [query orderByDescending:@"createdAt"];
    NSArray *resultObjects = [query findObjects];
    self.userCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
    //    }
    // Return all tags
    //    POQRequest rqst = self.rqstCollectionPrivate[0];
    return self.userCollectionPrivate;
}


-(POQRequest *) getRequestWithUserId: (NSString *)userId createdAt:(NSDate *)date
//                       Block:(POQRequestBlock)block
{
    POQRequest *resultRqst;
    PFQuery *query = [POQRequest query];
    query.limit = 1;
    //    [query whereKey:@"requestUserId" equalTo:userId];
    [query whereKey:@"createdAt" equalTo:date];
    [query orderByDescending:@"createdAt"];
    NSArray *resultObjects = [query findObjects];
    if (query.countObjects != 0) {
        resultRqst = (POQRequest *)[resultObjects objectAtIndex:0];
    }
    return resultRqst;
}

-(POQSettings *) getSettingsWithUserType: (NSString *)poqUserType
{
    POQSettings *resultSettings;
    PFQuery *query = [POQSettings query];
    query.limit = 1;
    [query whereKey:@"typeOmschrijvingSet" equalTo:poqUserType];
    [query orderByDescending:@"createdAt"];
    NSArray *resultObjects = [query findObjects];
    if (query.countObjects != 0) {
        resultSettings = (POQSettings *)[resultObjects objectAtIndex:0];
    }
    settings = resultSettings;
    return resultSettings;
}
//**


-(void) getBuurtRequestsWithBlock:(POQBuurtRequestsBlock)block
{
    PFQuery *query = [POQRequest query];
    query.limit = 100;
    //    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    //    static double distance = 5;
    //    [query whereKey:@"location" nearGeoPoint:myLocation withinMiles: distance];
    //    [query orderByAscending:@"geoPoint"];
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
            self.userCollectionPrivate = [NSArray arrayWithArray:objects];    // make mutable
//            self.buurtAnnoSetPrivate = [self buurtSetLazy];
            [self getAnnos];
            block([self buurtSet], error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSMutableArray *) buurtSet
{
    return [[self buurtAnnoSetPrivate] copy];
}

-(NSMutableArray *) buurtSetLazy{
     return  [[NSMutableArray alloc] init];
}
-(void) getAnnos{
    NSMutableArray *setResult = [[NSMutableArray alloc] init];
    NSMutableArray *setId = [[NSMutableArray alloc] init];
    //add home user
    [setId addObject:[PFUser currentUser].objectId];
    [setResult addObject:[PFUser currentUser]];
    
    for (POQRequest *rqst in self.rqstCollectionPrivate) {
        for (int x = 0; x<3; x++) {
            NSLog(@"de vinketering");
        }
        if (![setId containsObject:rqst.requestUserId]) {
            [setId addObject:rqst.requestUserId];
            [setResult addObject:[rqst copy]];
            NSLog(@"rqst.requestUserId blok:%@", rqst.requestUserId);
        }
    }
    for (PFUser *user in self.userCollectionPrivate){
        
        NSString *schijt = user.objectId;
        if (![setId containsObject:schijt]) {
            [setId addObject:user.objectId];
            [setResult addObject:[user copy]];
            NSLog(@"user.userid blok: %@", user.objectId);
        }
    }
   
//    return setResult; //
    self.buurtAnnoSetPrivate = setResult;
}


-(NSArray *)getBuurtSet {
    NSArray *myArr = [self getUsers];
    myArr = nil;
    [self getAnnos];
    return self.buurtAnnoSetPrivate;
}



-(void) getBuurtUsers
{
    PFQuery *query = [PFUser query];
    query.limit = 100;
    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    static double distance = 5;
    [query whereKey:@"location" nearGeoPoint:myLocation withinMiles: distance];
    [query orderByAscending:@"geoPoint"];
    NSArray *resultObjects = [query findObjects];
    self.userCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
}


@end

    //    NSMutableArray *setResult = [[NSMutableArray alloc] init];
//    NSMutableArray *setId = [[NSMutableArray alloc] init];
//    //add home user
////    NSLog(@"%@",    [PFUser currentUser].objectId);
//    [setId addObject:[PFUser currentUser].objectId];
//    [setResult addObject:[PFUser currentUser]];
//
//    //    for (POQRequest *rqst in [self rqsts]){
////        NSLog(@"\n rqstTitle: %@; id:%@", rqst.requestTitle, rqst.requestUserId);
////    }
//    
//    for (POQRequest *rqst in [self getRqsts]) {
//        if (![setId containsObject:rqst.requestUserId]) {
//            [setId addObject:rqst.requestUserId];
//            [setResult addObject:rqst];
////        } else {
////            NSLog(@"\n id %@ bestaat voor rqst %@", rqst.requestUserId, rqst.requestTitle);
//        }
//    }
////    ;
//    NSMutableArray *myuserCollectionPrivate = [[self getUsers] copy];
//    for (PFUser *user in myuserCollectionPrivate){
//        //[self userCollectionPrivate]) {
//        if (![setId containsObject:user.objectId]) {
//            [setId addObject:user.objectId];
//            [setResult addObject:user];
////        } else {
////            NSLog(@"\n id bestaat voor user %@", user.objectId);
//        }
//    }
//    return setResult;

// recommended getter, starts background task and calls the block when it's finished.
//-(void) getAllRqstsWithBlock:(POQAllRqstsBlock)block
//{
//    // Clear private array
//    // [self.tagCollectionPrivate removeAllObjects];
//
//    NSString *rqstClass = [POQRequest parseClassName];
//    // Retrieve all tags from Parse
//    PFQuery *query = [PFQuery queryWithClassName:rqstClass];
//    // query.cachePolicy = kPFCachePolicyNetworkElseCache;
//    // Add every tag-object from query to 1 array filled with TAATag instances
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);
//            // Do something with the found objects
//            //            for (PFObject *object in objects) {
//            //                POQRequest *aRqst = (POQRequest *)object;
//            ////                NSLog(@"%@", aRqst);
//            //            }
//            // store in cache
//            self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:objects];    // make mutable
//            block(objects, error);
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//}


//-(NSMutableArray *) getBuurtSetWithBlock:(POQBuurtSetBlock)block
//-(void) getBuurtSetWithBlock:(POQBuurtSetBlock)block
//{
//    NSLog(@"Waarom kon je hier niet-11");
//    NSMutableArray *setResult = [[NSMutableArray alloc] init];
//    NSMutableArray *setId = [[NSMutableArray alloc] init];
//    //add home user
//    [setId addObject:[PFUser currentUser].objectId];
//    [setResult addObject:[PFUser currentUser]];
//    NSLog(@"Waarom kon je hier niet0");
//    [self getBuurtUsersWithBlock:^(NSArray *objectsUsers, NSError *error) {
//        if (!error) {
//            for (PFUser *user in _userCollectionPrivate){
//                if (![setId containsObject:user.objectId]) {
//                    [setId addObject:user.objectId];
//                    [setResult addObject:[user copy]];
//                    NSLog(@"user.userid blok: %@", user.objectId);
//                }
//            }
//            NSLog(@"Waarom kon je hier niet1");
//
//            [self getBuurtRequestsWithBlock:^(NSArray *objectsRqsts, NSError *errorTje) {
//                if (!errorTje) {
//
//                for (POQRequest *rqst in _rqstCollectionPrivate) {
//                    for (int x = 0; x<3; x++) {
//                        NSLog(@"de vinketering");
//                    }
//                    if (![setId containsObject:rqst.requestUserId]) {
//                        [setId addObject:rqst.requestUserId];
//                        [setResult addObject:[rqst copy]];
//                        NSLog(@"rqst.requestUserId blok:%@", rqst.requestUserId);
//                    }
//                }
//                NSLog(@"Waarom kon je hier niet2");
//
//                    self.buurtAnnoSetPrivate = [setResult copy];
//                block(objectsUsers, error);
//                } else {
//                    NSLog(@"errortje");
//                }
//            }];
//        }
//    }];
////    return self.buurtAnnoSetPrivate;
//}
//
//    NSMutableSet *set1 = [[NSMutableSet alloc] init];
//    NSMutableSet *set2 = [[NSMutableSet alloc] init];
//    
//    set1 = [NSMutableSet setWithArray:[self getRqsts]];
//    set2 = [NSMutableSet setWithArray:[self getUsers]];
//    
////    NSMutableSet *set1 = [NSMutableSet setWithObjects:[self getRqsts], nil];
////    NSMutableSet *set2 = [NSMutableSet setWithObjects:[self getUsers], nil];
////    POQRequest *resultRqst = [[POQRequest alloc] init] ;
//    NSSet *result = [[set1 unionSet:set2] copy];
//    return result;
////    [NSMutableSet setWithObjects:@"Eezy",@"Tutorials", resultRqst, nil];
//    
//}
/*- unionSet:
 Adds each object in another given set to the receiving set, if not present.
 
 NSMutableSet *set1 = [NSMutableSet setWithObjects:@"Eezy",@"Tutorials", nil];
 NSMutableSet *set2 = [NSMutableSet setWithObjects:@"Website",@"Tutorials", nil];
 [set1 unionSet:set2];
 NSLog(@"%@",set1);
 
 Output

 Eezy,
 Tutorials,
 Website
 */
