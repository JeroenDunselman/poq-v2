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
static BOOL haveAlreadyReceivedCoordinates = NO;

#pragma mark - localization
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(haveAlreadyReceivedCoordinates) {
        return;
    }
    haveAlreadyReceivedCoordinates = YES;
    [manager stopUpdatingLocation];
    NSLog(@"didUpdateLocations");
    CLLocation *newLocation = locations[[locations count] -1];
    [self reverseGeocode:newLocation];
    CLLocationCoordinate2D currentCoordinate = newLocation.coordinate;
    currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    
    PFUser *currentUser = [PFUser currentUser];
    if ([PFUser currentUser]) {
        
        [currentUser setObject:currentPoint forKey:@"location"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Saved location to user");
                [[self delegate] poqLocationVCDidLocalize:YES];
            }
        }];
    } else {
        [[self delegate] showMapForLocation:currentPoint];
    }
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
            NSLog( @"Saved postcode to user");
        }
    }];
}

- (void)initLocaMgr {
    locationManager = [[CLLocationManager alloc] init];//
    [locationManager setDelegate:self];
    if (![[self delegate] needsLocaReg]) {
        [locationManager requestWhenInUseAuthorization];//niet hier
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDistanceFilter:100.0f];
        //    [locationManager startUpdatingLocation];
        //    [worldView setDelegate:self];
    } else { //?
//        [self btnRefreshLoca:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (![[self delegate] needsLocaReg]) {
//        [self startLocalizing];
    }
}

- (void)startLocalizing {
//    if ([[self delegate] needsLocaReg]){
//        [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"Loca", @"FB", @"Invite", @"Notif", nil]];
//    } else {
            haveAlreadyReceivedCoordinates = NO;
        [locationManager startUpdatingLocation];
//    }
}

#pragma mark - viewcontrol
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =   [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    //    self.tabBarItem.title = @"YOUR VIEW NAME";
    //    self.title = nibNameOrNil; //
    //    VCName = nibNameOrNil;
    //    [self.view.center = self.view.superview.center];
//    self.view.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
//    NSString *nm = self.className;
//    NSLog(@"initWithNibName locavw");
    
    
    return self;
}

//- (void)viewDidAppear:(BOOL)animated{
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    haveAlreadyReceivedCoordinates = NO;
    [self initLocaMgr];
    if (![[self delegate] needsLocaReg]) {
        self.lblLocaDesc.text = @"...";
        if (![PFUser currentUser] ){
            //currentUser nog niet geregistreerd.
            //vh 'bij inlog wordt startLocalizing aangeroepen'
        } else {
            //toon laatst bewaarde locatie als postcode
            NSString *userZipcode = [[PFUser currentUser] objectForKey:@"postcode"];
            self.lblLocaDesc.text = userZipcode;
        }
    } 
    if ([self.parentViewController isKindOfClass:[POQRequestVC class]]) {
        NSLog(@"pvc");
    }
//    if ([[self descTab] isEqualToString:@"Buurt"]) {
        NSLog(@"initWithNibName locavw");
    
//    [self.view setBackgroundColor: [UIColor colorWithWhite:0.54 alpha:0.72]];
         //[UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0]];
//        self.lblLocaDesc.backgroundColor =
//    [UIColor colorWithWhite:0.54 alpha:0.0];
//    self.lblLocaDesc.textColor =[UIColor colorWithWhite:1.0 alpha:1.0];
//    //self.view.backgroundColor;
//    }
    
}

-(NSString *)descTab{
    return _descTab;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRefreshLoca:(id)sender
{
    self.lblLocaDesc.text = @"...";
    if (![[self delegate] needsLocaReg]) {
        //    [locationManager startUpdatingLocation];
#pragma mark - todo self delegate startLocalizing
        [self startLocalizing];
    } else {
        NSMutableArray *theArr = [NSMutableArray arrayWithObjects:@"Loca", @"FB", @"Notif", nil];
        [[self delegate] requestPermissionWithTypes:theArr];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
