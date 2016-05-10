//
//  POQRequestTVC.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 06/11/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "POQRequestStore.h"
#import "POQLocationVC.h"
#import "CoreLocation/CoreLocation.h"

@protocol POQRequestTVCDelegate <NSObject>
@required
//- (void) poqLocationVCDidLocalize: (BOOL)success;
- (BOOL) didSelectUnlocalized; //
- (BOOL) needsLocaReg;
- (void) didSelectInviteBuurt;
- (void) didSelectUnregistered;
- (void) showMapForLocation:(PFGeoPoint *)locaPoint withDistance:(int) distance;
-(void)showConvoVCForRequest:(POQRequest *)rqst;
-(void)refreshBuurt;
//- (void) requestPermissionWithTypes:(NSMutableArray *)Types;
@end

@interface POQRequestTVC : UITableViewController<CLLocationManagerDelegate>{
    id <POQRequestTVCDelegate> delegate;
    CLLocationManager *locationManagerTVC;
}
@property (retain) id delegate;
//@property BOOL hasFullUserPrivilege;
@property (nonatomic) NSMutableArray *rqsts;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) void *reloadLocalizedData;
//@property BOOL userpermissionForGPS;
@end
