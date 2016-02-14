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

POQLocationVC *locaBuurtVC;
POQRequestTVC *locaBuurtTV;
PFGeoPoint *mapLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showBuurtLocaVw];
//    [locaBuurtVC startLocalizing];
    [self showBuurtTV];
    [self showMap];
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
        annotationView.image = [UIImage imageNamed:@"user anno.png"];
        if ([myAnno.pointType isEqualToString:@"Thuis"]) {
            annotationView.image = [UIImage imageNamed:@"home anno.png"];
        }
    } else {
//        annotationView.image = [UIImage imageNamed:@"poq shout tab.png"];
    }
    annotationView.annotation = annotation;
    
    return annotationView;
}
- (void) makeAnno {
//
    [[POQRequestStore sharedStore] getBuurtUsersWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"xyz");
//             self.usersBuurt = [[[POQRequestStore sharedStore] getRqsts] copy];
        }
    }];
    
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
    POQMapPoint *mpHome = [[POQMapPoint alloc] InitWithCoordinate:myLoca title: @"Mijn poq lokatie." pointType:@"Thuis"];
    
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

- (void) showMap {
    [worldView showsUserLocation];
    [worldView showsPointsOfInterest];
    [worldView setDelegate:self];
    
    mapLocation = [[PFUser currentUser] objectForKey:@"location"];
    CLLocation *mapCenter = [[CLLocation alloc] initWithLatitude:mapLocation.latitude longitude:mapLocation.longitude];
    CLLocationCoordinate2D coord = [mapCenter coordinate];
    [worldView removeAnnotations:worldView.annotations];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
    [worldView setRegion:region animated:YES];
    [self makeAnno];
}

- (void) showBuurtTV {
    locaBuurtTV = [[POQRequestTVC alloc] initWithNibName:@"POQRequestTVC" bundle:nil];
    locaBuurtTV.layerClient = self.layerClient;
    locaBuurtTV.userpermissionForGPS = locaBuurtVC.hasLocationManagerEnabled;
    [self addChildViewController:locaBuurtTV];
    [self.vwData addSubview:locaBuurtTV.view];
    [locaBuurtTV didMoveToParentViewController:self];
}

- (void) showBuurtLocaVw {
    locaBuurtVC = [[POQLocationVC alloc] init];
    [locaBuurtVC setDelegate:self];
    [self addChildViewController:locaBuurtVC];
    [self.vwBuurtLoca addSubview:locaBuurtVC.view];
//    [self.vwBuurtLoca center];
    [locaBuurtVC didMoveToParentViewController:self];
}

-(void) poqLocationVCDidLocalize:(BOOL)success{
    NSLog(@"POQBuurtVC.didLocalize: start reloadLocalizedData");
    [locaBuurtTV reloadLocalizedData];
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
