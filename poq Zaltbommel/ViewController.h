//
//  ViewController.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Parse/Parse.h>
//#import <LayerKit/LayerKit.h>
//#import <ParseUI.h>
#import "MyConversationListViewController.h"
//#import <AVKit/AVKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "POQRequestStore.h" //testing download
@interface ViewController : UIViewController <LYRQueryControllerDelegate> //PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, FBSDKLoginButtonDelegate

@property (weak, nonatomic) IBOutlet UIView *vwContainer;

@property (weak, nonatomic) IBOutlet UIImageView *vwLogo;
@property (nonatomic) LYRClient *layerClient;
//@property (nonatomic) PFLogInViewController *logInViewController;
//@property (nonatomic, retain) UIViewController *rqstVC;
//@property (weak, nonatomic) AVPlayer *player ;
@end

