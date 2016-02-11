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

@protocol POQLocationVCDelegate <NSObject>
@required
- (void) poqLocationVCDidLocalize: (BOOL)success;
@end

@interface POQLocationVC : UIViewController
<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    id <POQLocationVCDelegate> delegate;
}
@property (retain) id delegate;
//-(void)startSomeProcess;
- (void) startLocalizing;
@property (weak, nonatomic) IBOutlet UILabel *lblLocaDesc;
@property (strong, nonatomic) PFGeoPoint *currentPoint;
- (IBAction) btnRefreshLoca:(id)sender;

// non-blocking method which gets all tags from the server, the block returns with the updated array
//- (void) startLocalizingWithBlock:(POQLocalizedBlock)block;

@end
