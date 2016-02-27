//
//  POQLocationVC.h
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 03/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import <Parse/Parse.h>
#import "POQPermissionVC.h"

@protocol POQLocationVCDelegate <NSObject>
@required
- (void) poqLocationVCDidLocalize: (BOOL)success;
- (void) showMapForLocation:(PFGeoPoint *)locaPoint;
- (BOOL) needsLocaReg;
- (void) requestPermissionWithTypes:(NSMutableArray *)Types;
@end

@interface POQLocationVC : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    id <POQLocationVCDelegate> delegate;
}
@property BOOL hasLocationManagerEnabled;
@property (retain) id delegate;
//-(void)startSomeProcess;
- (void) startLocalizing;
@property (weak, nonatomic) IBOutlet UILabel *lblLocaDesc;
- (IBAction) btnRefreshLoca:(id)sender;

// non-blocking method which gets all tags from the server, the block returns with the updated array
//- (void) startLocalizingWithBlock:(POQLocalizedBlock)block;

@end
