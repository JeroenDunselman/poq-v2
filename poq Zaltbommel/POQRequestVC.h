/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>
#import "POQLocationVC.h"
#import "POQSettings.h"
//@interface POQRequestVC : UIViewController <UITextFieldDelegate, POQLocationVCDelegate>


//**
@protocol POQRequestVCDelegate <NSObject>
@required
//- (void) attemptedUnregisteredPostWithVC:(UIViewController *)permissionVC;
- (void) requestPermissionWithTypes:(NSMutableArray *)Types;
- (POQSettings *) theSettings;
- (BOOL) needsLocaReg;
- (BOOL) needsNotifReg;
- (BOOL) needsFBReg;
@end

@interface POQRequestVC : UIViewController<UITextFieldDelegate, POQLocationVCDelegate,UIScrollViewDelegate>
{
    id <POQRequestVCDelegate> delegate;
}

@property (retain) id delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//**

//@property BOOL hasFullUserPrivilege;
//@property BOOL permission2Post; = !(needsFBReg||needsLocaReg)
//@property BOOL unregisteredNotifs; = needsLocaReg

//@property BOOL needsFBReg;
//@property BOOL needsNotifReg;
//@property BOOL needsLocaReg;
@property (weak, nonatomic) IBOutlet UILabel *lblProdukt;

@property (weak, nonatomic) IBOutlet UIView *vwPost;
@property (weak, nonatomic) IBOutlet UIImageView *vwSymbol;
@property (weak, nonatomic) IBOutlet UIImageView *vwOtherSymbol;
@property (nonatomic) LYRClient *layerClient;
@property (weak, nonatomic) IBOutlet UIView *vwLoca;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (weak, nonatomic) IBOutlet UITextField *textPrice;
//@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *layerUserId;
@property (weak, nonatomic) IBOutlet UITextField *textItemRequested;
@property (weak, nonatomic) IBOutlet UITextField *curItemPriceFetch;
@property (weak, nonatomic) IBOutlet UITextField *curItemPriceBring;
@property (weak, nonatomic) IBOutlet UISwitch *switchFetch;
@property (weak, nonatomic) IBOutlet UISwitch *switchBring;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scSupplyDemand;
- (IBAction)scSupplyDemandChange:(UISegmentedControl *)sender;
- (void) saveRequest;
@property (weak, nonatomic) IBOutlet UILabel *lblHdrPrice;

@end
