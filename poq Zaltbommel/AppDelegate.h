//
//  AppDelegate.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "CoreLocation/CoreLocation.h"
#import "ViewController.h"
#import "POQPermissionVC.h"
#import "POQRequestVC.h"
#import "POQRequestTVC.h"
#import "POQBuurtVC.h"
#import "POQLocationVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, POQPermissionVCDelegate, POQRequestVCDelegate, POQBuurtVCDelegate, POQLocationVCDelegate, CLLocationManagerDelegate>
//, LYRClientDelegate>
//- (void) showInviteFBFriendsPage:(id *)sender;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *controller;
@property (nonatomic) LYRClient *layerClient;
//@property (nonatomic) CLLocationManager *POQLocationManager;
//@property (nonatomic, retain) dispatch_queue_t backgroundQueue;

//@property BOOL needsFBReg;
//@property BOOL needsNotifReg;
//@property BOOL needsLocaReg;

@end

/*  
 delegate maken voor het afhandelen van permissionrequest
-requestVC.attemptedPost
-buurtVC.tappedCellMaakJeLocatieBekend
 [self delegate requestPermissions]

-btnInviteFB

 requestPermissions:
 missingPermissions = getMissingPermissions
 permissionVC withMissingPermissions:getMissingPermissionsWithVC:
 
 */