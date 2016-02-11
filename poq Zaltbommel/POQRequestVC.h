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
#import "POQLocationVC.h"
@interface POQRequestVC : UIViewController <UITextFieldDelegate, POQLocationVCDelegate>
@property (weak, nonatomic) IBOutlet UIView *vwLoca;
@property (weak, nonatomic) IBOutlet UITextField *textPrice;
@property (nonatomic, retain) NSString *userId;
@property (weak, nonatomic) IBOutlet UITextField *textItemRequested;
@property (weak, nonatomic) IBOutlet UITextField *curItemPriceFetch;
@property (weak, nonatomic) IBOutlet UITextField *curItemPriceBring;
@property (weak, nonatomic) IBOutlet UISwitch *switchFetch;
@property (weak, nonatomic) IBOutlet UISwitch *switchBring;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scSupplyDemand;
- (IBAction)scSupplyDemandChange:(UISegmentedControl *)sender;
- (void) saveRequest;

@end
