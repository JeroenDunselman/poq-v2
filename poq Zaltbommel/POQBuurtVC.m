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
#import "MapKit/MapKit.h"
#import "POQRequestStore.h"

@interface POQBuurtVC ()

@end

@implementation POQBuurtVC
@synthesize delegate;
POQLocationVC *buurtLocaVC;
POQRequestTVC *buurtRequestTVC;
PFGeoPoint *mapLocation;

//protocol POQRequestTVC
- (void) didSelectInviteBuurt
{
    [[self delegate] showInviteBuurt];
}
//komen op hetzelfde neer, wellicht interessant voor tracking
- (void) didSelectUnlocalized{
    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"Loca", @"FB", @"Invite", @"Notif", nil]];
}

- (void) didSelectUnregistered{
    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"FB", @"Invite", @"Notif", nil]];
}
//
- (BOOL) needsFBReg{
    return [[self delegate] needsFBReg];
}

- (BOOL) needsLocaReg{
    return [[self delegate] needsLocaReg];
}

- (void)requestPermissionWithTypes:(NSMutableArray *)Types{
//    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"Loca", nil]];
    [[self delegate] requestPermissionWithTypes:Types];
}

- (void) reloadLocalizedData {
    [buurtRequestTVC reloadLocalizedData];
}

- (void *) localizationStatusChanged {
    [self reloadLocalizedData];
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[worldView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
    }
    POQMapPoint *myAnno = (POQMapPoint *)annotation;
    if (myAnno.pointType) {
//        CGRect imgSize = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = [UIImage imageNamed:@"poq annotatie 60.png"];
        
//        annotationView.image = [UIImage imageNamed:@"user anno.png"];
        [annotationView addSubview:imgView];
        if ([myAnno.pointType isEqualToString:@"Thuis"]) {
            imgView.image = [UIImage imageNamed:@"Home Filled-100.png"];
            [annotationView addSubview:imgView];
//            annotationView.image = [UIImage imageNamed:@"home anno.png"];
        }
    } else {
//        annotationView.image = [UIImage imageNamed:@"poq shout tab.png"];
    }
    annotationView.annotation = annotation;
    
    return annotationView;
}

- (void) makeAnno
{
    [[POQRequestStore sharedStore] getBuurtRequestsWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (POQRequest *rqst in objects) {
                NSString *titleString = @"hatseflats";
                PFGeoPoint *thePoint = rqst.requestLocation;
//                [[PFUser currentUser] objectForKey:@"location"];
                
                CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:(thePoint.latitude) longitude:thePoint.longitude];
                CLLocationCoordinate2D myLoca = [currentLocation coordinate];
                if ([rqst.requestLocationTitle isEqualToString:[PFUser currentUser].username]) {
                    POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: @"Mijn Poq lokatie." pointType:@"Thuis"];
                    [worldView addAnnotation:mpHome];
                } else {
                    POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: @"Mijn Poq lokatie." pointType:@"Niet Thuis"];
                    [worldView addAnnotation:mpHome];
                }
                
//                NSLog(@"xyz: %@", rqst.requestTitle);
            }
//            self.rqstsBuurt = [[[POQRequestStore sharedStore] getRqsts] copy];
            
        }
    }];
}

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
    POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: @"Mijn Poq lokatie." pointType:@"Thuis"];
    
    
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

- (void) showMapForLocation:(PFGeoPoint *)locaPoint {
    CLLocation *mapCenter = [[CLLocation alloc] initWithLatitude:locaPoint.latitude longitude:locaPoint.longitude];
    CLLocationCoordinate2D coord = [mapCenter coordinate];
    [worldView removeAnnotations:worldView.annotations];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
    [worldView setRegion:region animated:YES];
    [self makeAnno];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showBuurtLocaVw];
    //    [locaBuurtVC startLocalizing];
    [self showBuurtTV];
    [self showMap];
}

- (void) showBuurtTV {
    buurtRequestTVC = [[POQRequestTVC alloc] initWithNibName:@"POQRequestTVC" bundle:nil];
    buurtRequestTVC.view.frame = self.vwData.bounds;
    buurtRequestTVC.layerClient = self.layerClient;
//    buurtRequestTVC.userpermissionForGPS = ![self needsLocaReg];//buurtLocaVC.hasLocationManagerEnabled;
    [buurtRequestTVC setDelegate:self];
    [self addChildViewController:buurtRequestTVC];
    [self.vwData addSubview:buurtRequestTVC.view];
    [buurtRequestTVC didMoveToParentViewController:self];
}

- (void) showMap {
    [worldView showsUserLocation];
    [worldView showsPointsOfInterest];
    [worldView setDelegate:self];
    mapLocation = [[PFUser currentUser] objectForKey:@"location"];
    [self showMapForLocation:mapLocation];
}

- (void) showBuurtLocaVw {
    buurtLocaVC = [[POQLocationVC alloc] init];
//    [buurtLocaVC.view setBackgroundColor:   [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.1]];
//    [buurtLocaVC.view setBackgroundColor:[UIColor clearColor]];
    [buurtLocaVC setDelegate:self];
//    [buurtLocaVC setDelegate:[self delegate]];
    [self addChildViewController:buurtLocaVC];
    [self.vwBuurtLoca addSubview:buurtLocaVC.view];
//    [self.vwBuurtLoca center];
    [buurtLocaVC didMoveToParentViewController:self];
}

-(void) poqLocationVCDidLocalize:(BOOL)success{
    NSLog(@"POQBuurtVC.didLocalize: start reloadLocalizedData");
    [buurtRequestTVC reloadLocalizedData];
    [self showMap];
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

@end
