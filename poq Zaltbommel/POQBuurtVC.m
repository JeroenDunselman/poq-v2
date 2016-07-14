//
//  POQBuurtVC.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 07/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//
#import "POQMapPoint.h"
#import "POQBuurtVC.h"
#import "POQLocationVC.h"
#import "POQRequestTVC.h"
#import "POQActieTVC.h"
#import "MapKit/MapKit.h"
#import "POQRequestStore.h"
#import "POQRequest.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import "Mixpanel.h"
@interface POQBuurtVC ()
@end
@implementation POQBuurtVC

@synthesize delegate;
POQLocationVC *buurtLocaVC;
POQRequestTVC *buurtRequestTVC;
POQActieTVC *buurtActieTVC;

PFGeoPoint *mapLocation;
NSArray *buurtUsers;
NSArray *buurtRqsts;
NSArray *buurtActies;
NSArray *buurtAnnoSet;

//protocol POQRequestTVC
- (void) didSelectInviteBuurt
{
    [[self delegate] showInviteBuurt];
}
//komen op hetzelfde neer, wellicht interessant voor tracking
- (void) didSelectUnlocalized{
    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"Loca", @"FB", @"Notif", nil]]; //@"Invite",
}

- (void) didSelectUnregistered{
    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"FB", @"Notif", nil]]; //@"Invite",
}
//
- (BOOL) needsFBReg{
    return [[self delegate] needsFBReg];
}

- (BOOL) needsLocaReg{
    return [[self delegate] needsLocaReg];
}

//waarom stond dit uit?
- (void *) localizationStatusChanged {
    [buurtLocaVC startLocalizing];
    [buurtRequestTVC reloadLocalizedData];
    return nil;
}

- (void)requestPermissionWithTypes:(NSMutableArray *)Types{
//    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"Loca", nil]];
    [[self delegate] requestPermissionWithTypes:Types];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";
    MKAnnotationView *annotationView = (MKAnnotationView *)[worldView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
    } else {
        [[annotationView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    POQMapPoint *myAnno = (POQMapPoint *)annotation;
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (myAnno.imgAvatarAvailable) {
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.cornerRadius = imgView.frame.size.width / 2;
        imgView.clipsToBounds = YES;
        imgView.layer.borderWidth = 1.0f;
        imgView.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    UIImage *theImg = [myAnno imgAvatar];
    if ([myAnno.pointType isEqualToString:@"home"]){
        // start pin
        static NSString *StartPinIdentifier = @"StartPinIdentifier";
        MKPinAnnotationView *startPin = [[MKPinAnnotationView alloc] init];
        
        if (startPin == nil) {
            startPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:StartPinIdentifier];
            startPin.animatesDrop = YES;
//            MKPinAnnotationColor *thePinColor =
//            startPin.pinTintColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
            annotationView.tintColor =  [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
            startPin.tintColor =  [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
            startPin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            startPin.canShowCallout = YES;
            startPin.enabled = YES;
            
//            UIImage *theImg = [UIImage imageNamed:@"location.png"];
//            UIImageView *imgView = [[UIImageView alloc] initWithImage:theImg];
//            startPin.leftCalloutAccessoryView = imgView;
        }
        
        annotationView = startPin;
    } else {
    
        imgView.image = theImg;
        [annotationView addSubview:imgView];
    }
    annotationView.annotation = annotation;
    
    return annotationView;
}

//- (void) makeAnnoWithBlock
//{
//    [[POQRequestStore sharedStore] getBuurtSetWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            [self makeAnnoWithObjects:[[POQRequestStore sharedStore] buurtSet]];
//        }
//    }];
//    
//}

- (void) makeAnnoWithObjects: (NSArray *) theAnnos
{
    [worldView removeAnnotations:worldView.annotations];
    NSString *title = @"POQ locatie";
    
//    NSMutableArray *theAnnos = [[POQRequestStore sharedStore] buurtSet];//buurtSetLazy
//    int i = 0;
    NSLog(@"[theAnnos count]: %lu", (unsigned long)[theAnnos count]);
//    NSString *desc = nil;
    NSString *userId = nil;
//    for (NSObject *o in theAnnos)
//    {
//        if ([o isKindOfClass:[POQRequest class]]) {
//            POQRequest *rqst = (POQRequest *)o;
//            desc = [NSString stringWithFormat:@"Desc objRqst %@",];
//        } else if ([o isKindOfClass:[PFUser class]]) {
//            PFUser *user = (PFUser *)o;
//            desc = [NSString stringWithFormat:@"Desc objUser %@",];
//        }
////        NSLog(@"ANNODesc%@", userId);
//    }
    
    for (NSObject *o in theAnnos)
    {
        PFGeoPoint *thePoint;
        NSString *imgType = nil;
        if ([o isKindOfClass:[POQRequest class]]) {
            POQRequest *rqst = (POQRequest *)o;
            userId = rqst.requestUserId;
            
            imgType = rqst.requestAnnoType;// [rqst requestAnnoType];
//            NSLog(@"\nHET REQUEST IS: %@",rqst.requestTitle );
            thePoint = rqst.requestLocation;
//            NSLog(@"\nPOQRequestUserId: %@", rqst.requestUserId);
        } else if ([o isKindOfClass:[PFUser class]]) {
            PFUser *user = (PFUser *)o;
            userId = user.objectId;
            if (user.objectId == [PFUser currentUser].objectId) {
                imgType = @"home";
//                NSLog(@"\nhomeId: %@", user.objectId);
            } else {
                imgType = @"poquser"; //[rqst requestAnnoType];
//                NSLog(@"\npoquserId: %@", user.objectId);
            }
            if ([user objectForKey:@"location"]){
                thePoint = [user objectForKey:@"location"];
//                NSLog(@"\ntheUserPoint found");
            } else {
//                NSLog(@"\ntheUserPoint NOT found");
            }
            
//            user = nil;
        }
        if (imgType == nil) {
            NSLog(@"\n\nimgType nil");
        }
        //                [[PFUser currentUser] objectForKey:@"location"];
        CLLocation *annoLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude) longitude:thePoint.longitude];
        //todo niet nil maar (0.0;0.0)
//        CLLocationCoordinate2DIsValid(myCoordinate))
// NSLog(@"l:%f;d:%f", thePoint.latitude, thePoint.longitude);
        if (annoLocation != nil) {
#pragma mark - todo filepath van imgAvatar ophalen uit rqstStore.avatars voor rqst/pfuser .userId en meegeven (mogelijk nil) aan mappoint. Neen.
            CLLocationCoordinate2D myLoca = [annoLocation coordinate];
            POQMapPoint *mpHome;
            if ([o isKindOfClass:[POQRequest class]]) {
                 mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: title pointType:imgType avatarPath:userId];//
            } else if ([o isKindOfClass:[PFUser class]]) {
                mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: title pointType:imgType];
            }
            [worldView addAnnotation:mpHome];
        } else {
            NSLog(@"annoLocation not added for nil");
        }
       
    }
    return;
    
    
//    [[POQRequestStore sharedStore] getBuurtRequestsWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
////            NSString *imgType = nil;
////            for (POQRequest *rqst in objects)
////            {
////                imgType = [rqst requestAnnoType];
////                PFGeoPoint *thePoint = rqst.requestLocation;
//////                [[PFUser currentUser] objectForKey:@"location"];
////                CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude) longitude:thePoint.longitude];
////                CLLocationCoordinate2D myLoca = [currentLocation coordinate];
////                POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: title pointType:imgType];
////                    [worldView addAnnotation:mpHome];
////            }
////            self.rqstsBuurt = [[[POQRequestStore sharedStore] getRqsts] copy];
//        }
//    }];
}

- (void) showMapForLocation:(PFGeoPoint *)locaPoint {
    [self showMapForLocation:locaPoint withDistance:1000];
}

- (void) showMapForLocation:(PFGeoPoint *)locaPoint withDistance:(int) distance {
    CLLocation *mapCenter = [[CLLocation alloc] initWithLatitude:locaPoint.latitude longitude:locaPoint.longitude];
    CLLocationCoordinate2D coord = [mapCenter coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, distance, distance);
    [worldView setRegion:region animated:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    [self refreshBuurt];
    [SVProgressHUD dismiss];
}

//- (void) viewWillDisappear:(BOOL)animated{
//    [SVProgressHUD show];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showBuurtLocaVw];
//        [locaBuurtVC startLocalizing];
    
    [self showBuurtTV];
//    [self refreshBuurt];
    
    [self showMap];
    /*
     willappear
     svprogresshud
     refreshBuurt
     
     delegate method refreshBuurt voor TV pulldown gesture
     store getBuurt:
     getRqsts -> TV
     getAnno
     
     */
}

-(void) refreshBuurt{
    //#pragma mark - door buurtvw willappear laten afhandelen
    //    self.rqsts = [[[POQRequestStore sharedStore] getRqsts] copy];
    [SVProgressHUD show];
    
    //v2
    buurtRqsts = [[POQRequestStore sharedStore] getRqsts];
//    v3
    buurtActies = [[POQRequestStore sharedStore] getActies];
//    POQActie *anAction = [buurtActies objectAtIndex:0];
//    NSLog(@"actieAmbaID: %@", anAction.actieAmbaID);
   //v2
    buurtRequestTVC.rqsts = [buurtRqsts copy];
    //v3
    buurtActieTVC.acties = [buurtActies copy];
    
    [buurtRequestTVC.tableView reloadData];
    [buurtActieTVC.tableView reloadData];
    
    buurtUsers = [[POQRequestStore sharedStore] getUsers];
    [self makeBuurtSet];
    if (!([self needsFBReg] || [self needsLocaReg])) {
        [self makeAnnoWithObjects:buurtAnnoSet];
    }
    [self showMap];
    [SVProgressHUD dismiss];
}

-(void) poqLocationVCDidLocalize:(BOOL)success{
    NSLog(@"POQBuurtVC.didLocalize: start reloadLocalizedData");
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Lokatie gevonden tabBuurt"];
    
    [self refreshBuurt];
    [self showMap];
}

-(void) makeBuurtSet{
    NSMutableArray *setResult = [[NSMutableArray alloc] init];
    NSMutableArray *setId = [[NSMutableArray alloc] init];
    //add home user
    if ([PFUser currentUser]) {
        [setId addObject:[PFUser currentUser].objectId];
        [setResult addObject:[PFUser currentUser]];
    }
    
    for (POQRequest *rqst in buurtRqsts) {
        if (rqst.requestUserId != nil) {
            if (![setId containsObject:rqst.requestUserId]) {
                [setId addObject:rqst.requestUserId];
                [setResult addObject:rqst];
                NSLog(@"rqst.requestUserId makeBuurtSet:%@", rqst.requestUserId);
            }
        } else{
            NSLog(@"objrqst is nil");
        }
    }
    for (PFUser *user in buurtUsers){
        if (user != nil) {
            
        NSString *schijt = (NSString *)user.objectId;
        if (![setId containsObject:schijt]) {
            [setId addObject:user.objectId];
            [setResult addObject:user ];
//            NSLog(@"user.userid blok: %@", user.objectId);
        }
        }else{
            NSLog(@"objuser is nil");
        }
    }
    
    //    return setResult; //
    buurtAnnoSet = [setResult copy];
}

- (void) showBuurtTV {
//    [[POQRequestStore sharedStore] getBuurtRequestsWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {

    //v2
    buurtRequestTVC = [[POQRequestTVC alloc] initWithNibName:@"POQRequestTVC" bundle:nil];
    buurtRequestTVC.view.frame = self.vwData.bounds;
    buurtRequestTVC.layerClient = self.layerClient;
    //    buurtRequestTVC.userpermissionForGPS = ![self needsLocaReg];//buurtLocaVC.hasLocationManagerEnabled;
    [buurtRequestTVC setDelegate:self];
    /*[self addChildViewController:buurtRequestTVC];
    [self.vwData addSubview:buurtRequestTVC.view];
    [buurtRequestTVC didMoveToParentViewController:self];
    */
    
    //v3
    buurtActieTVC = [[POQActieTVC alloc] initWithNibName:@"POQRequestTVC" bundle:nil];
    buurtActieTVC.view.frame = self.vwData.bounds;
//    [buurtActieTVC setDelegate:self];
    
    [self addChildViewController:buurtActieTVC];
    [self.vwData addSubview:buurtActieTVC.view];
    [buurtActieTVC didMoveToParentViewController:self];
}

- (void) showMap {
//    NSLog(@"showMap");
////    NSMutableArray *theAnnos = [[NSMutableArray alloc] init];
//    [[POQRequestStore sharedStore] getBuurtUsersWithBlock:^(NSArray *objects, NSError *error) {
//        NSLog(@"[worldView.annotations count]: %lu", (unsigned long)[worldView.annotations count]);
        //theAnnos = objects;//[[POQRequestStore sharedStore] buurtSet];
    
        [worldView showsUserLocation];
        [worldView setShowsPointsOfInterest:false];
//    worldview shows
        [worldView setDelegate:self];
        mapLocation = [[PFUser currentUser] objectForKey:@"location"];
        [self showMapForLocation:mapLocation];
//    }];
}

- (void) showBuurtLocaVw {
    buurtLocaVC = [[POQLocationVC alloc] init];
//    [buurtLocaVC.view setBackgroundColor:   [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.1]];
//    [buurtLocaVC.view setBackgroundColor:[UIColor clearColor]];
    [buurtLocaVC setDelegate:self];
//    [buurtLocaVC setDelegate:[self delegate]];
//    buurtLocaVC.view.center = self.view.center;
    
//    buurtLocaVC.view.center = self.view.convertPoint(self.view.center, fromView: buurtLocaVC.view);
    
   
    self.vwBuurtLoca.contentMode = UIViewContentModeCenter;
//    child.center = [parent convertPoint:parent.center fromView:parent.superview];
    CGPoint cntrSelf = self.view.center;
    CGPoint cntrVW = buurtLocaVC.view.center;
    CGFloat x = self.view.bounds.size.width;
    CGFloat y = self.view.frame.size.width;
    CGFloat z = self.view.superview.bounds.size.width;
//    self.view.center = CGPointMake(400, 400);
//    [self.view convertPoint:self.view.center toView:buurtLocaVC.view];
//    buurtLocaVC.view.center = cntr;
    
    [self addChildViewController:buurtLocaVC];
//    self.vwBuurtLoca.center = self.view.center;
    //CGPointMake(self.view.bounds.size.height/2, self.view.bounds.size.width/2);
    [self.vwBuurtLoca addSubview:buurtLocaVC.view];
//    [self.vwBuurtLoca center];
    [buurtLocaVC didMoveToParentViewController:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =   [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    self.view.center = CGPointMake(400, 400);
//    self.view.center = CGPointMake(-100, -100);
    //self.view.bounds.origin;
//    .origin =  CGPointMake(400, 400);
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) testing{
    //
    //    [[POQRequestStore sharedStore] getBuurtUsersWithBlock:^(NSArray *objects, NSError *error) {
    //        if (!error) {
    //            NSLog(@"xyz");
    //             self.usersBuurt = [[[POQRequestStore sharedStore] getUsers] copy];
    //        }
    //    }];
    /*
     MKAnnotationView *myAnno = [[MKAnnotationView alloc] init];
     CLPlacemark *placemark = [placemarks lastObject];
     NSString *titleString = [NSString stringWithFormat:@"%@, %@", spot.spotVIP, spot.spotLocationTitle];
     TAAMapPoint *mP = [[TAAMapPoint alloc] InitWithCoordinate:(placemark.location.coordinate) title: titleString];
     [self.mapView addAnnotation:mP];
     CLPlacemark *placemark = [placemarks lastObject];*/
    
    NSString *titleString = @"hatseflats";
    PFGeoPoint *thePoint = [[PFUser currentUser] objectForKey:@"location"];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude) longitude:thePoint.longitude];
    CLLocationCoordinate2D myLoca = [currentLocation coordinate];
    POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: @"Mijn Poq locatie." pointType:@"Thuis"];
    
    
    POQMapPoint *mP2 = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: titleString];
    
    currentLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude + 0.003f) longitude:thePoint.longitude];
    myLoca = [currentLocation coordinate];
    POQMapPoint *mP3 = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: titleString pointType:@"default"];
    
    currentLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude + 0.0045f) longitude:(thePoint.longitude + 0.002)];
    myLoca = [currentLocation coordinate];
    POQMapPoint *mP4 = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: titleString pointType:@"default"];
    
    [worldView addAnnotation:mpHome];
    [worldView addAnnotation:mP2];
    [worldView addAnnotation:mP3];
    [worldView addAnnotation:mP4];
}
@end
