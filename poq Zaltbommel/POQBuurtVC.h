//
//  POQBuurtVC.h
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 07/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//
#import "MapKit/MapKit.h"
#import <UIKit/UIKit.h>
#import "POQLocationVC.h"
#import "POQRequestStore.h"

@protocol POQBuurtVCDelegate <NSObject>
@required
//- (void) attemptedUnregisteredCellTapWithVC:(UIViewController *)buurtVC;
- (void) showInviteBuurt; // -> appdel showInvite
@end
@interface POQBuurtVC : UIViewController <POQLocationVCDelegate, MKMapViewDelegate>
{
    IBOutlet MKMapView *worldView;
    id <POQBuurtVCDelegate> delegate;
}
@property (retain) id delegate;
@property (nonatomic) void *localizationStatusChanged;

@property BOOL hasFullUserPrivilege;
@property (weak, nonatomic) IBOutlet UIView *vwBuurtLoca;
@property (weak, nonatomic) IBOutlet UIView *vwData;
@property (weak, nonatomic) IBOutlet MKMapView *vwMap;
@property (nonatomic) NSMutableArray *usersBuurt;
@property (nonatomic) NSMutableArray *rqstsBuurt;
@property (nonatomic) LYRClient *layerClient;
@end
