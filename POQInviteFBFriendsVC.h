//
//  POQInviteFBFriendsVC.h
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 01/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface POQInviteFBFriendsVC : UIViewController <FBSDKAppInviteDialogDelegate>
- (IBAction)btnWA:(id)sender;
- (IBAction)btnFB:(id)sender;
@end

