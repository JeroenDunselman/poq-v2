//
//  POQInviteFBFriendsVC.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 01/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "POQInviteFBFriendsVC.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface POQInviteFBFriendsVC ()

@end

@implementation POQInviteFBFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];

    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/460185444167156"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    
//     present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
}

- (void)setNavBarLogo {
    
    [self setNeedsStatusBarAppearanceUpdate];
    CGRect myImageS = CGRectMake(0, 0, 38, 38);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:myImageS];
    [logo setImage:[UIImage imageNamed:@"btn invite.png"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logo;
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Facebook App Invite Delegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"app invite result: %@", results);
    
    BOOL complete = [[results valueForKeyPath:@"didComplete"] boolValue];
    NSString *completionGesture = [results valueForKeyPath:@"completionGesture"];
    
    // NOTE: the `cancel` result dictionary will be
    // {
    //   completionGesture = cancel;
    //   didComplete = 1;
    // }
    // else, it will only just `didComplete`
    
    if (completionGesture && [completionGesture isEqualToString:@"cancel"]) {
        // handle cancel state...
        return;
    }
    
    if (complete) { // if completionGesture is nil -> success
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Your invite has been sent.", nil)];
    }
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    NSLog(@"app invite error: %@", error.localizedDescription);
    // handle error...
}

- (void)dismissMyView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
