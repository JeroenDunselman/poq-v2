//
//  POQSettingsVC.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 01/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQSettingsVC.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Mixpanel.h"
@interface POQSettingsVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblValueSliderUitgaand;
@property (weak, nonatomic) IBOutlet UILabel *lblValueSliderInkomend;
- (IBAction)sliderUitgaand:(id)sender;
- (IBAction)sliderInkomend:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderIn;
@property (weak, nonatomic) IBOutlet UISlider *sliderUit;
- (IBAction)btnLogoutFB:(id)sender;
- (IBAction)btnFAQ:(id)sender;


@end

@implementation POQSettingsVC
BOOL useAvatar;
- (void)setNavBarLogo {
    
    [self setNeedsStatusBarAppearanceUpdate];
    CGRect myImageS = CGRectMake(0, 0, 38, 38);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:myImageS];
    [logo setImage:[UIImage imageNamed:@"btn settings.png"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logo;
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"POQSettingsViewDidLoad" ];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];
    [self setNavBarLogo];
    useAvatar = (![[[PFUser currentUser] objectForKey:@"useAvatar"] isEqualToString: @"false"]);
    [self.swAvatar setOn:useAvatar];
    //set sliders
    NSString *setting = [[PFUser currentUser] objectForKey:@"sliderUit"];
    int myInt = [setting intValue];
    [self.sliderUit setValue:myInt];
    self.lblValueSliderUitgaand.text = [NSString stringWithFormat:@"[%i m]", myInt];
    
    //setting is disabled
    setting = @"5000"; //[[PFUser currentUser] objectForKey:@"sliderIn"];
    myInt = [setting intValue];
    [self.sliderIn setValue:myInt];
    self.lblValueSliderInkomend.text = [NSString stringWithFormat:@"[%i m]", myInt];
    self.sliderIn.enabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissMyView {
    PFUser *theUser = [PFUser currentUser];
    //save settings to PFUser
    NSString *sliderVal = [NSString stringWithFormat:@"%.f", [self.sliderIn value]];
    //static @ 5000 m for now
    //[theUser setObject:sliderVal forKey:@"sliderIn"];
    
    sliderVal = [NSString stringWithFormat:@"%.f", [self.sliderUit value]];
    [theUser setObject:sliderVal forKey:@"sliderUit"];
    NSString *strSetAvatarUse = useAvatar?@"true":@"false";
    [theUser setObject:strSetAvatarUse forKey:@"useAvatar"];

    [theUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved settings to user");
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)btnLogoutFB:(id)sender {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"btnLogoutFB" ];
}

- (IBAction)switchUseAvatar:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    useAvatar = theSwitch.isOn;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"switchUseAvatar" ];
}

- (IBAction)btnFAQ:(id)sender {
    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://poqapp.nl/#!faq/kj830" ];
    //    http://www.poqapp.nl/#!uitleg/cctor
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)sliderUitgaand:(id)sender {
    self.lblValueSliderUitgaand.text = [NSString stringWithFormat:@"[%.f m]", [(UISlider *)sender value]];
}

- (IBAction)sliderInkomend:(id)sender {
    self.lblValueSliderInkomend.text = [NSString stringWithFormat:@"[%.f m]", [(UISlider *)sender value]];
}
@end
