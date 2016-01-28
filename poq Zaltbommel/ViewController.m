//
//  ViewController.m
//  Layer-Parse-iOS-Example
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UserManager.h"
#import "ATLConstants.h"
#import "POQRequestVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FirstInstallVC.h"
#import "POQRequestTVC.h"
//@import AVFoundation;
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVPlayer.h>
//#import <AVFoundation/AVAudioPlayer.h>

@interface PFImage : UIImage

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;
//@property (nonatomic)
@end

@implementation ViewController

@synthesize layerClient;// = _layerClient; //@dynamic
POQRequestVC *rqstVC = nil;
POQRequestTVC *rqstTVC = nil;
AVPlayer *animPlayer;
AVPlayerViewController *playerViewController;
LYRQueryController *queryController;
//FBSDKLoginButton *loginButton;
MyConversationListViewController *convoListVC;

-(void)viewDidLoad {
    FirstInstallVC *lockVC = [[FirstInstallVC alloc] initWithNibName:@"FirstInstall" bundle:nil];
    lockVC.layerClient = self.layerClient;

    //quick fix top control pos to navbar in both orientations
    self.navigationController.navigationBar.translucent = NO;

    //tmp omzeilen login vanwege  Uh oh. The user cancelled the Facebook login.

    if (![PFUser currentUser] ){
        [self.navigationController pushViewController:lockVC animated:YES];
    } else {
        [lockVC loginLayer];
    }

    //set up query delegate for unread msgs
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread"  predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"receivedAt" ascending:NO] ];
    NSError *error;
    queryController = [self.layerClient queryControllerWithQuery:query error:&error];
    [queryController execute:&error];
    queryController.delegate = self;
    
    //testing the POQRequestTVC
    //rqstVC = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
//    POQRequestTVC *rqstTVC = [[POQRequestTVC alloc] init];
//    rqstTVC.view.frame = self.view.frame;
//    rqstTVC.layerClient = self.layerClient;
//    [self.navigationController pushViewController:rqstTVC animated:YES];

}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    if (queryController.count > 0)
    {
        [self presentConversationListViewController];
//        if ([UIApplication sharedApplication].applicationState !=UIApplicationStateActive) {
//            LYRMessage *theMsg = [queryController objectAtIndexPath:0];
//            LYRActor *fromUser = theMsg.sender;
//            NSLog(@"from user %@", fromUser.name);
//            LYRMessagePart *messagePart = theMsg.parts[0];
//            NSString *msg = [[NSString alloc ] initWithFormat:@"%@", [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]];
//            NSString *notif = [[NSString alloc] initWithFormat:@"%@: \n%@", @"poq bericht", msg ];
//            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//            NSDate *currentTime = [NSDate date];
//            localNotification.fireDate = currentTime;
//            localNotification.alertBody = notif; //@"Nieuw bericht poq";
//            localNotification.alertAction = @"Toon bericht";
//            localNotification.timeZone = [NSTimeZone defaultTimeZone];
//            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
//            localNotification.soundName = UILocalNotificationDefaultSoundName;//@"default";
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    [self playPoqAnim];
    NSLog(@"current: %@", [PFUser currentUser]);
}

- (void)getFacebookProfile {
//    NSString *urlString = [NSString
//                           stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",
//                           [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURL *url = [NSURL URLWithString:urlString];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request setDidFinishSelector:@selector(getFacebookProfileFinished:)];
//    
//    [request setDelegate:self];
//    [request startAsynchronous];
  
}

#pragma mark - IBActions

- (IBAction)btnUitleg:(id)sender {
    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://poqapp.nl/#!uitleg/cctor" ];
//    http://www.poqapp.nl/#!uitleg/cctor
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Present ATLPConversationListController
- (IBAction)btnConvoList:(id)sender {
    [self presentConversationListViewController];
//    wijziging testing source control
}

- (void)presentConversationListViewController
{
    //issue: convo update vanuit requestTVC niet zichtbaar
    if (![[self.navigationController viewControllers] containsObject:convoListVC ]) {
        convoListVC = [MyConversationListViewController  conversationListViewControllerWithLayerClient:self.layerClient];
        [self.navigationController pushViewController:convoListVC animated:YES];
    }
    //else
}

- (IBAction)btnRequestTVC:(id)sender {
    [SVProgressHUD dismiss];
    if (!rqstTVC) {
        rqstTVC = [[POQRequestTVC alloc] initWithNibName:@"POQRequestTVC" bundle:nil];
        rqstTVC.layerClient = self.layerClient;
        rqstTVC.view.frame = self.view.frame;
    }
    [self.navigationController pushViewController:rqstTVC animated:YES];
}

#pragma mark - Present PoqrequestVC
- (IBAction)btnPoqRequest:(id)sender {
    [self presentPoqrequestVC];
}


- (void)presentPoqrequestVC
{
    [SVProgressHUD dismiss];
    if (!rqstVC) {
        rqstVC = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
        rqstVC.userId = self.layerClient.authenticatedUserID;
        rqstVC.view.frame = self.view.frame;
    }
    [self.navigationController pushViewController:rqstVC animated:YES];
}


#pragma mark - Animation

- (void)playPoqAnim //
{
    if ([PFUser currentUser] ) {
        NSString *resourceName = @"Poq logo animatie.mp4"; //ook toevoegen resource
        NSString* movieFilePath = [[NSBundle mainBundle]
                                   pathForResource:resourceName ofType:nil];
        NSAssert(movieFilePath, @"movieFilePath is nil");
        NSURL *fileURL = [NSURL fileURLWithPath:movieFilePath];
        animPlayer = [[AVPlayer alloc] initWithURL:fileURL];
        [animPlayer setAllowsExternalPlayback:YES];
        playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = animPlayer;
        playerViewController.showsPlaybackControls = false;
        playerViewController.view.frame = self.vwContainer.frame; //vwContainer
        playerViewController.view.backgroundColor = [UIColor clearColor];
        [self.vwContainer addSubview:playerViewController.view];
        [animPlayer play];
    }
}

@end

//niet connected in example proj
//- (IBAction)logOutButtonTapAction:(id)sender
//{
//    [PFUser logOut];
//    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSLog(@"Failed to deauthenticate: %@", error);
//        } else {
//            NSLog(@"Previous user deauthenticated");
//        }
//    }];
//
//    [self presentViewController:self.logInViewController animated:YES completion:NULL];
//}

//authenticate viewDidLoad
//v1: layer:   if (![PFUser currentUser] ){ [self showLoginSignup];

//v2: loginbutton
//        loginButton = [[FBSDKLoginButton alloc] init];
//        loginButton.delegate = self;
//        loginButton.center = self.view.center;
//        loginButton.readPermissions =
//        @[@"public_profile", @"email", @"user_friends"];
//        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
//        [self.view addSubview:loginButton];

//- (void)  loginButton:(FBSDKLoginButton *)loginButton
//didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
//error:(NSError *)error {
//    //    NSLog(@"htsflts");
//}
//
//-(void)profileUpdated:(NSNotification *) notification{
//    NSLog(@"User name: %@",[FBSDKProfile currentProfile].name);
//    NSLog(@"User ID: %@",[FBSDKProfile currentProfile].userID);
//    //    [self.view delete:loginButton];
//    [loginButton removeFromSuperview];
//}
//
//- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
//    
//}

//- (void)showLoginSignup
//{
//    if (![PFUser currentUser] ) { // No user logged in
//        // Create the log in view controller
//        self.logInViewController = [[PFLogInViewController alloc] init];
//
//        [self.logInViewController.logInView.passwordForgottenButton setTitleColor:ATLBlueColor() forState:UIControlStateNormal];
//        UIImage *loginBackgroundImage = [PFImage imageWithColor:ATLBlueColor() cornerRadius:4.0f];
//        [self.logInViewController.logInView.signUpButton setBackgroundImage:loginBackgroundImage forState:UIControlStateNormal];
//        self.logInViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        self.logInViewController.fields = (PFLogInFieldsUsernameAndPassword |
//                                           PFLogInFieldsLogInButton |
//                                           PFLogInFieldsSignUpButton |
//                                           PFLogInFieldsPasswordForgotten);
//        self.logInViewController.delegate = self;
//        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LayerParseLogin"]];
//        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.logInViewController.logInView.logo = logoImageView;
//
//        // Create the sign up view controller
//        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
//        UIImage *signupBackgroundImage = [PFImage imageWithColor:ATLBlueColor() cornerRadius:0.0f];
//        [signUpViewController.signUpView.signUpButton setBackgroundImage:signupBackgroundImage forState:UIControlStateNormal];
//        [self.logInViewController setSignUpController:signUpViewController];
//        signUpViewController.delegate = self;
//        UIImageView *signupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LayerParseLogin"]];
//        signupImageView.contentMode = UIViewContentModeScaleAspectFit;
//        signUpViewController.signUpView.logo = signupImageView;
//
//        [self presentViewController:self.logInViewController animated:YES completion:nil];
//    }
//    else{
//        [self loginLayer];
//    }
//    [SVProgressHUD dismiss];
//}
//#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
//- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
//{
//    if (username && password && username.length && password.length) {
//        return YES; // Begin login process
//    }
//
//    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
//    return NO; // Interrupt login process
//}

// Sent to the delegate when a PFUser is logged in.
//- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self loginLayer];
//}
//
//- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
//{
//    NSLog(@"Failed to log in...");
//}

//#pragma mark - PFSignUpViewControllerDelegate
//
//// Sent to the delegate to determine whether the sign up request should be submitted to the server.
//- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
//{
//    BOOL informationComplete = YES;
//
//    // loop through all of the submitted data
//    for (id key in info) {
//        NSString *field = [info objectForKey:key];
//        if (!field || !field.length) { // check completion
//            informationComplete = NO;
//            break;
//        }
//    }
//
//    // Display an alert if a field wasn't completed
//    if (!informationComplete) {
//        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
//    }
//
//    return informationComplete;
//}
//
//// Sent to the delegate when a PFUser is signed up.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self loginLayer];
//}
//
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
//{
//    NSLog(@"Failed to sign up...");
//}

//- (IBAction)btnLogout:(id)sender {
//    [self logoutButtonTapped];
//}
//
//- (void)logoutButtonTapped
//{
//    NSLog(@"logOutButtonTapAction");
//
//    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
//        if (!error) {
//            [PFUser logOut];
//            [self showLoginSignup];
////            [self.navigationController popToRootViewControllerAnimated:YES];
//        } else {
//            NSLog(@"Failed to deauthenticate: %@", error);
//        }
//    }];
//}

////    lp example
//    static NSString *const LayerAppIDString = @"layer:///apps/staging/0e7b0b8c-5def-11e5-b579-4fd01f000f3c";
//    //     Initializes a LYRClient object
//    NSURL *appID = [NSURL URLWithString:LayerAppIDString];
//    self.layerClient = [LYRClient clientWithAppID:appID];
//    self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation, nil];

////
////  ViewController.m
////  Poq Requester
////
////  Created by Jeroen Dunselman on 02/10/15.
////  Copyright © 2015 Jeroen Dunselman. All rights reserved.
////
//
//#import "ViewController.h"
//#import "POQRequest.h"
//#import "POQRequestVC.h"
//@interface ViewController ()
////@property (nonatomic, strong) POQRequestVC *episodePageVC;
//
//@end
//@implementation ViewController
//- (void)viewDidLoad {
//    [super viewDidLoad];
//  //    NSString *myS =  @"requestTitle test";
////    rqst.requestTitle = myS;
////    [rqst saveInBackground];
////    // Do any additional setup after loading the view, typically from a nib.
//    self.rqstVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        [self presentViewController:rqstVC animated:YES completion:NULL];
//}
//-(void)viewDidAppear:(BOOL)animated{
//
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

//- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
//{
//    //    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
////    [self playPoqAnim];
//    //    switch (orientation){}
//}
//[[NSNotificationCenter defaultCenter]
// addObserver:self
// selector:@selector(deviceOrientationDidChangeNotification:)
// name:UIDeviceOrientationDidChangeNotification
// object:nil];
//@end
