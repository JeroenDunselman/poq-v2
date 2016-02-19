//
//  POQLocationVC.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 03/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQLocationVC.h"
#import <AddressBook/AddressBook.h>
#import "POQRequestStore.h"
#import "POQRequestVC.h"
#import "POQRequestTVC.h"
@interface POQLocationVC ()

@end

@implementation POQLocationVC
@synthesize delegate; //currentPoint,
PFGeoPoint *currentPoint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =   [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    //    self.tabBarItem.title = @"YOUR VIEW NAME";
//    self.title = nibNameOrNil; //
//    VCName = nibNameOrNil;
//    [self.view.center = self.view.superview.center];
    NSLog(@"initWithNibName locavw");
    return self;
}

//- (void)viewDidAppear:(BOOL)animated{
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initLocaMgr];
    self.lblLocaDesc.text = @"...";
    if (![PFUser currentUser] ){
        //currentUser nog niet geregistreerd. bij inlog wordt startLocalizing aangeroepen
    } else {
        //toon laatst bewaarde locatie als postcode
        NSString *userZipcode = [[PFUser currentUser] objectForKey:@"postcode"];
        self.lblLocaDesc.text = userZipcode;
        //  PFGeoPoint *thePoint = [[PFUser currentUser] objectForKey:@"location"];
        //       CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:thePoint.latitude longitude:thePoint.longitude];
        //       if (currentLocation) {
        //           [self reverseGeocode:currentLocation];
        //       }
    }
}



- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];

    CLLocation *newLocation = locations[[locations count] -1];
    [self reverseGeocode:newLocation];
    CLLocationCoordinate2D currentCoordinate = newLocation.coordinate;
    currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    [[self delegate] poqLocationVCDidLocalize:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:currentPoint forKey:@"location"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved location to user");
        }
    }];
}

//maakt van een CLLocation een nette adresstring en toont MP
- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
//            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
            NSString *zipCode = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressZIPKey];
            self.lblLocaDesc.text = zipCode;
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:zipCode forKey:@"postcode"];
        }
    }];
}
- (void)initLocaMgr {
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //1.7 [als] de app geen toegang heeft tot de GPS van het apparaat, zal de app een pop-up weergeven.
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDistanceFilter:10.0f];
    //    [locationManager startUpdatingLocation];
    //    [worldView setDelegate:self];
    
    //set status of permission
    self.hasLocationManagerEnabled = false;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        self.hasLocationManagerEnabled = true;
    }
}

- (void)showPermissionPage{
    NSLog(@"showPermissionPage called");
    POQPermissionVC *permissionVC = [[POQPermissionVC alloc] initWithNibName:@"POQPermissionVC" bundle:nil];
    [self addChildViewController:permissionVC];
//    permissionVC.view.frame = self.parentViewController.view.frame;
//    [[permissionVC view] setFrame:[[self.parentViewController view] bounds]];[[UIScreen mainScreen] bounds]
    NSLog(@"%f", self.view.frame.origin.x);
    CGRect rect = CGRectMake(-100, -100, 200, 300);
   
    [[permissionVC view] setFrame: rect];
    [self.view addSubview:permissionVC.view];
}
/*
 
 -(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
 //    NSLog(@"Location: %@", newLocation);
 NSTimeInterval t =[[newLocation timestamp] timeIntervalSinceNow];
 if (t<-180) {
 return;
 }
 //    [self foundLocation:newLocation];
 }
 
 -(void)foundLocation:(CLLocation *)loc{
 [self reverseGeocode:loc];
 CLLocationCoordinate2D coord = [loc coordinate];
 //    DTT_RSR_MapPoint *mp = [[DTT_RSR_MapPoint alloc] InitWithCoordinate:coord
 //                                                                  title:[self.textLocationDescription text]];
 //    [worldView removeAnnotations:worldView.annotations];
 //    [worldView addAnnotation:mp];
 //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 10, 100);
 //    [worldView setRegion:region animated:YES];
 [locationManager stopUpdatingLocation];
 }
 */
/*
//-(void) mapView:(MKMapView *)mapview didUpdateUserLocation:
//(MKUserLocation *)userLocation {
//    //zoom
//    CLLocationCoordinate2D loc = [userLocation coordinate];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
//    [worldView setRegion:region animated:YES];
//    [locationManager startUpdatingLocation];
//}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Could not find location: %@", error);
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRefreshLoca:(id)sender {

    self.lblLocaDesc.text = @"...";
//    [locationManager startUpdatingLocation];
    [self startLocalizing];
}

- (void)startLocalizing {
    if (!self.hasLocationManagerEnabled){
        //1.3. Wanneer de GPS van het mobiele device is uitgeschakeld,
        //wordt de gebruiker gevraagd om de GPS van het mobiele device te activeren.
#pragma mark - todo vwUitleg
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GPS niet ingeschakeld"
//                                                        message:@"Activeer GPS via Instellingen."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        [self showPermissionPage];
    
    } else {
        [locationManager startUpdatingLocation];
    }
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
