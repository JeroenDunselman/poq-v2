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
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface POQRequestStore ()
//**
@property (nonatomic) NSArray *rqstCollectionPrivate;
@property (nonatomic) NSArray *rqstDummyCollectionPrivate;
@property (nonatomic) NSArray *userCollectionPrivate;
//**
@property (nonatomic) NSArray *buurtAnnoSetPrivate;
@property (nonatomic, retain) NSMutableArray *fakeLocations;

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
-(void)getRqstDummies
{
    NSString *rqstClass = [POQRequest parseClassName];
    PFQuery *query = [PFQuery queryWithClassName:rqstClass];
    NSDate *now = [NSDate date];
    int yearsValid = 1;
    NSDateComponents *years = [NSDateComponents new];
    [years setYear:yearsValid];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *minExpiry = [cal dateByAddingComponents:years toDate:now options:0];
    [query whereKey:@"requestExpiration" greaterThan:minExpiry];
//    NSString *strHrs = [settings objectForKey:@"urenAanbodGeldig"];
    //    int numHrs = [strHrs intValue];
    ////    NSString *string = @"5";
    ////    int value = [string intValue];
    //
    //    NSDateComponents *hrs = [NSDateComponents new];
    //    [hrs setHour:-numHrs];
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    //    NSDate *hrsAgo = [cal dateByAddingComponents:hrs toDate:now options:0];
    //    [query whereKey:@"createdAt" greaterThan:hrsAgo];
    
    // Limit what could be a lot of points.
    query.limit = 50;
    
    NSArray *resultObjects = [query findObjects];
    self.rqstDummyCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
//    return self.rqstDummyCollectionPrivate;
}

-(NSArray *)getRqsts
{
    //    if (!self.rqstCollectionPrivate) {
    NSString *rqstClass = [POQRequest parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:rqstClass];
    //        query.cachePolicy = kPFCachePolicyNetworkElseCache; crash
    
    //    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    //    [query whereKey:@"de_guardia" equalTo:@"Si"];
#pragma mark - BS:urenGeldig moet gebruikt bij requestVC.saveinbackground om expiredate te bepalen. getRqsts moet kwerien op expiredate > nu
//    int numDays = 15;
//    NSDateComponents *days = [NSDateComponents new];
//    [days setDay:-numDays];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *daysAgo = [cal dateByAddingComponents:days toDate:now options:0];
//    [query whereKey:@"createdAt" greaterThan:daysAgo];
//    NSString *strHrs = [settings objectForKey:@"urenAanbodGeldig"];
//    int numHrs = [strHrs intValue];
////    NSString *string = @"5";
////    int value = [string intValue];
//    
//    NSDateComponents *hrs = [NSDateComponents new];
//    [hrs setHour:-numHrs];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *hrsAgo = [cal dateByAddingComponents:hrs toDate:now options:0];
//    [query whereKey:@"createdAt" greaterThan:hrsAgo];
    
    //minimumdate
    NSDate *now = [NSDate date];
    [query whereKey:@"requestExpiration" greaterThan:now];
    //maximumdate, to exclude the dummies (expirydated 2030)
    int yearsValid = 1;
    NSDateComponents *years = [NSDateComponents new];
    [years setYear:yearsValid];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *maxExpiry = [cal dateByAddingComponents:years toDate:now options:0];
    [query whereKey:@"requestExpiration" lessThan:maxExpiry];
//    [query orderByDescending:@"requestExpiration"];
    
    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    [query whereKey:@"requestLocation" nearGeoPoint:myLocation];
    //    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    //    static double distance = 5;
    //    [query whereKey:@"location" nearGeoPoint:myLocation withinMiles: distance];
    //    [query orderByAscending:@"geoPoint"];
    // Limit what could be a lot of points.
    query.limit = 50;

    NSArray *resultObjects = [query findObjects];
    for (POQRequest *rqst in resultObjects){
        NSLog(@"requestAvatarLocation:%@", rqst.requestAvatarLocation);
    }
    NSMutableArray *resultArr = [NSMutableArray arrayWithArray:resultObjects];
    if ([resultObjects count] < 7) {
        if (_rqstDummyCollectionPrivate == nil) {
//            NSArray *dummies = [self getRqstDummies];
            [self getRqstDummies];
        }
        if (_fakeLocations == nil) {
            [self makeFakeLocations];
        }
        NSLog(@"fakes: %lu", (unsigned long)[self.fakeLocations count]);
        for (int i = 0; i<[self.rqstDummyCollectionPrivate count]; i++){
            POQRequest *rqst = [self.rqstDummyCollectionPrivate objectAtIndex:i];
//            PFGeoPoint *loca = rqst.requestLocation;
//            double lo = loca.longitude;
//            double la = loca.latitude;
//            NSLog(@"lo:%f", lo );
//            NSLog(@"la:%f", la );

            rqst.requestLocation = [self.fakeLocations objectAtIndex:i];
//                                    ([self.fakeLocations count] % i)];
//            PFGeoPoint *locab = rqst.requestLocation;
//            double lob = locab.longitude;
//            double lab = locab.latitude;
//            NSLog(@"lob:%f", lob );
//            NSLog(@"lab:%f", lab );
        }
        [resultArr addObjectsFromArray:self.rqstDummyCollectionPrivate];
    }
    //
#pragma mark - todo check if all avatars available, else download them and store in self.avatars
    [self checkForMissingAvatarsWithRequestsArray:resultArr];
     //]self.rqstCollectionPrivate];
    self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:resultArr];
    return self.rqstCollectionPrivate;
}

-(void) checkForMissingAvatarsWithRequestsArray:rqsts{
    if (!self.avatars) {
        self.avatars = [[NSMutableDictionary alloc] init];
    }
    for (POQRequest *rqst in rqsts) {
        NSString *locAvatar = rqst.requestAvatarLocation;
        if (locAvatar) {
            if (!self.avatars[rqst.requestUserId]) {
                NSDictionary *newAvatar =
                @{rqst.requestUserId:@""};
                [self.avatars addEntriesFromDictionary:newAvatar];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *filePath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", rqst.requestUserId]];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:rqst.requestAvatarLocation]];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if (error) {
                        NSLog(@"Download Error:%@",error.description);
                    }
                    if (data) {
                        [data writeToFile:filePath atomically:YES];
                        NSLog(@"File is saved to %@",filePath);
//                         [self.avatars setObject:filePath forKey:rqst.requestUserId];
                        NSLog(@"SET %@ FOR %@", filePath, rqst.requestUserId);
                        
                        UIImage *avatar = [[UIImage alloc] initWithContentsOfFile:filePath];
                        [self.avatars setObject:avatar forKey:rqst.requestUserId];
                    }
                }];
                
            } //not already available
        } //has url avatar or older signup without this value
    }//each rqst
}
//downloadImgAvatarWithBlock:[self.avatars setObject:downloadedImage forKey:rqst.requestAvatarLocation];


            /*NSURL *url = [NSURL URLWithString:rqst.requestAvatarLocation];
            NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:url];
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
            self.downloadTask = [self.urlSession downloadTaskWithRequest:downloadRequest];
            [self.downloadTask resume];*/
            
//            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
//                                                                           parameters:nil];
//            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                // TODO: handle results or error of request.
//            }];
            
          /*  [FBRequestConnection
             startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:rqst.requestAvatarLocation]]];
                     
                     
//                     [self.tableView reloadData];
                 }
             }];*/


//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location
//{
//    if (![[NSFileManager defaultManager] fileExistsAtPath: [location path]])
//    {
//        NSLog(@"Error. File not found");
//        return;
//    }
//    //    ...
//}

-(void)makeFakeLocations{
    self.fakeLocations = [[NSMutableArray alloc] init];
    for (int i = 0; i<[self.rqstDummyCollectionPrivate count]; i++) {
        PFGeoPoint *ptCurrent = [[PFUser currentUser] objectForKey:@"location"];
        PFGeoPoint *ptNew = [[PFGeoPoint alloc] init];
        
        double d = ptCurrent.latitude;
        int j = i + 1;
        d = d + 0.01*j*j;
        ptNew.latitude = d;
//        NSLog(@"lat:%f", d);
        d = ptCurrent.longitude;
        d = d + 0.02/(j);
        ptNew.longitude = d;
//        NSLog(@"lon:%f", d);
        
        [self.fakeLocations addObject:ptNew];
    }
}

//    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"requestDistance" ascending:YES];
//    NSMutableArray *theRqsts = [resultObjects copy];
//    [theRqsts sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
//    self.rqstCollectionPrivate = [NSMutableArray arrayWithArray:theRqsts];
//
//    NSSortDescriptor *sortDescriptor;
//    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"birthDate"
//                                                 ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray *sortedArray = [theRqsts sortedArrayUsingDescriptors:sortDescriptors];
//    
//sortedArray; //



-(NSArray *)getUsers {
    //    if (!self.rqstCollectionPrivate) {
    NSString *userClass = [PFUser parseClassName];
    // Retrieve all tags from Parse
    PFQuery *query = [PFQuery queryWithClassName:userClass];
    PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"location"];
    [query whereKey:@"location" nearGeoPoint:myLocation];
    // Limit what could be a lot of points.
    query.limit = 50;
//    [query orderByDescending:@"createdAt"];
    NSArray *resultObjects = [query findObjects];
    self.userCollectionPrivate = [NSMutableArray arrayWithArray:resultObjects];
    return self.userCollectionPrivate;
}
//    NSDate *now = [NSDate date];
//    NSDateComponents *days = [NSDateComponents new];
//    [days setDay:-1];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *oneDayAgo = [cal dateByAddingComponents:days toDate:now options:0];
//    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
//


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
