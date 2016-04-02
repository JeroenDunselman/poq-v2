    //
//  FirstInstallVC.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 28/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "FirstInstallVC.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "Parse/Parse.h"
#import "POQRequest.h"
#import "POQLocationVC.h"
#import "Mixpanel.h"

@interface FirstInstallVC ()

@end

@implementation FirstInstallVC
@synthesize delegate;

//POQLocationVC *firstLocaVC;


//- (BOOL) needsLocaReg{
//    return [[self delegate] needsLocaReg];
//}

- (IBAction)btnAttemptSignup:(id)sender {
    [self attemptSignup];
}

- (void *) attemptSignup {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //authenticate parse/fb
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:nil];
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", nil];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [mixpanel track:@"The user cancelled the Facebook login."];
        } else {
            NSLog(@"%@", [PFUser currentUser].username);
            if (user.isNew) {
                //apply default settings
#pragma mark - todo move value to parse
//                [[PFUser currentUser] setObject:@"5000" forKey:@"sliderIn"];
//                [[PFUser currentUser] setObject:@"5000" forKey:@"sliderUit"];
                [[PFUser currentUser] setObject:@"default" forKey:@"PoqUserType"];
                [[PFUser currentUser] setObject:@"false" forKey:@"UserIsBanned"];
                [[PFUser currentUser] setObject:@"true" forKey:@"useAvatar"];
                
                //get FB username to register as Layer username
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"email,name,gender,age_range,birthday"}]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                        //
                         // After logging in with Facebook
//                         [FBRequestConnection
//                          startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              if (!error) {
//                                  NSString *facebookId = [result objectForKey:@"id"];
//                              }
//                          }];
                        
//                         [[PFUser currentUser] objectForKey:facebookId]
//                         NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
//                         [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
                        //
                        
                         if(result)
                         {
                             if ([result objectForKey:@"id"]) {
                                 NSString *strURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [result objectForKey:@"id"]];
//                                 NSURL *profilePictureURL = [NSURL URLWithString:strURL];
                                 
                                 [[PFUser currentUser] setObject:strURL forKey:@"profilePictureURL"];
//                                 .profilePictureURL = profilePictureURL;
                             }
                             
                             if ([result objectForKey:@"email"]) {
                                 [PFUser currentUser].email = [result objectForKey:@"email"];
                             }
                             if ([result objectForKey:@"gender"]) {
                                 [[PFUser currentUser] setObject:[result objectForKey:@"gender"] forKey:@"gender"];
                             }
                             if ([result objectForKey:@"age_range"]) {
                                 [[PFUser currentUser] setObject:[result objectForKey:@"age_range"] forKey:@"age_range"];
                             }
                             if ([result objectForKey:@"birthday"]) {
                                 [[PFUser currentUser] setObject:[result objectForKey:@"birthday"] forKey:@"birthday"];
                             }
                             if ([result objectForKey:@"name"]) {
                                 NSLog(@"User name : %@",[result objectForKey:@"name"]);
                                 [PFUser currentUser].username = [result objectForKey:@"name"];
                                 
                                 [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                     if (!error) {
                                         // The currentUser saved successfully.
#if TARGET_IPHONE_SIMULATOR
                                         //        NSLog(@"Hello, FB testuser harry ebola!");
                                        
#else
                                         //attempt to get current PFUser.location
                                         //init locaview
                                         [self showFirstLocaVw];
//                                         [firstLocaVC startLocalizing];
#endif
                                         [self loginLayer];
                                     } else {
                                         // There was an error saving the currentUser.
                                         NSLog(@"Error saving User to Parse");
                                     }
                                 }];
                             }
                         }
                     } else {
                     
                     }
                     
                 }];
                NSLog(@"New user signed up and logged in through Facebook!");
                [mixpanel track:@"New user signed up and logged in through Facebook!"];
            } else {
                [self grabAvatarUrlForExistinguser];
                [self loginLayer];
                NSLog(@"Existing user logged in through Facebook!");
                NSLog(@"%@", [PFUser currentUser].username );
                [mixpanel track:@"Existing user logged in through Facebook!"];
            }
            [[self delegate] poqFirstInstallVCDidSignup];
        }   //FB returned valid user
    }]; //end login FB
    return nil;
}

-(void) grabAvatarUrlForExistinguser {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"email,name,gender,age_range,birthday"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *strURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [result objectForKey:@"id"]];
             [[PFUser currentUser] setObject:strURL forKey:@"profilePictureURL"];
             [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (!error) {
                     // The currentUser saved successfully.
                     NSLog(@"Existing User avatar saved to Parse");
#if TARGET_IPHONE_SIMULATOR
#else
#endif
                 } else {
                     // There was an error saving the currentUser.
                     NSLog(@"Error saving User to Parse");
                 }
             }];
         }
    }];
}

-(void) initChatWithPoqBot{
    NSString *msgInitChat = [[NSString alloc] initWithFormat:@"Hallo poq! Ik ben %@ en ik heb me zojuist aangemeld.", [[PFUser currentUser] username ]];
    NSString *convoTitle = [NSString stringWithFormat:@"Welkom %@", [[PFUser currentUser] username ]];
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: msgInitChat];
    NSArray *mA = @[part];
    NSError *error;
    LYRMessage *msgWelcome = [self.layerClient newMessageWithParts:mA
                                                           options:nil
                                                             error:&error];
    POQRequest *rqst = [[POQRequest alloc] init];
    LYRConversation *rqstConvo = [rqst requestConversationWithLYRClient:self.layerClient];

           NSDictionary *metadata = @{@"title" : convoTitle,
                                       @"theme" : @{
                                               @"background_color" : @"335333",
                                               @"text_color" : @"F8F8EC",
                                               @"link_color" : @"21AAE1"},
                                       @"created_at" : @"Dec, 01, 2014",
                                       @"img_url" : @"/path/to/img/url"};
            [rqstConvo setValuesForMetadataKeyPathsWithDictionary:metadata merge:YES];
            [rqstConvo sendMessage:msgWelcome error:&error];
}

#pragma mark - Layer Authentication Methods

- (void* )loginLayer
{
    [SVProgressHUD show];
    
    // Connect to Layer
    // See "Quick Start - Connect" for more details
    // https://developer.layer.com/docs/quick-start/ios#connect
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            
            PFUser *user = [PFUser currentUser];
            NSString *userID = user.objectId;
            [self authenticateLayerWithUserID:userID completion:^(BOOL success, NSError *error) {
                if (!error){
                    [SVProgressHUD dismiss];
                    if (user.isNew) {
                        [self initChatWithPoqBot];
                    }
//                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    if (self.isViewLoaded && self.view.window){
//                        [self.navigationController popViewControllerAnimated:YES];
//                        self.navigationController.navigationBarHidden = NO;
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } 
                } else {
                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                }
            }];
        }
    }];
    return nil;
}

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion
{
    // Check to see if the layerClient is already authenticated.
    if (self.layerClient.authenticatedUserID) {
        // If the layerClient is authenticated with the requested userID, complete the authentication process.
        if ([self.layerClient.authenticatedUserID isEqualToString:userID]){
            NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
            if (completion) completion(YES, nil);
            return;
        } else {
            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error){
                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
                        if (completion){
                            completion(success, error);
                        }
                    }];
                } else {
                    if (completion){
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        // If the layerClient isn't already authenticated, then authenticate.
        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
            if (completion){
                completion(success, error);
            }
        }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion
{
    /*1. Request an authentication Nonce from Layer*/
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        /*2. Acquire identity Token from Layer Identity Service*/
        NSDictionary *parameters = @{@"nonce" : nonce, @"userID" : userID};
        [PFCloud callFunctionInBackground:@"generateToken" withParameters:parameters block:^(id object, NSError *error) {
            if (!error){
                NSString *identityToken = (NSString*)object;
                [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (authenticatedUserID) {
                        if (completion) {
                            completion(YES, nil);
                        }
                        NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                        [SVProgressHUD dismiss];
                    } else {
                        completion(NO, error);
                    }
                }];
            } else {
                NSLog(@"Parse Cloud function failed to be called to generate token with error: %@", error);
            }
        }];
        
    }];
}
//-(void) attemptSignupWithBlock:(POQSignupBlock)block{
////    -?(void) getBuurtUsersWithBlock:(POQBuurtUsersBlock)block
////    if (!error) {
//        block(objects, error);
////    } else {
//        // Log details of the failure
//        NSLog(@"");
////    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
////    [self showFirstLocaVw];
//    [firstLocaVC setDelegate:self];
////    [firstLocaVC startLocalizing];
}

- (void) showFirstLocaVw {
//    firstLocaVC = [[POQLocationVC alloc] init];
//    [self addChildViewController:firstLocaVC];
//    [self.vwLoca addSubview:firstLocaVC.view];
//    [firstLocaVC didMoveToParentViewController:self];
}

-(void) poqLocationVCDidLocalize:(BOOL)success {
    NSLog(@"FirstInstall.didLocalize: Process completed");
}

- (IBAction)btnAlgemeneVoorwaarden:(id)sender {
    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://poqapp.nl/#!algemene-voorwaarden/uvwew" ];
    //    http://www.poqapp.nl/#!algemene-voorwaarden/uvwew
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dismissMyView {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
