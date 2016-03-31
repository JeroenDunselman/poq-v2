//
//  POQPermissionVC.m
//  POQPermission
//
//  Created by Jeroen Dunselman on 17/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQPermissionVC.h"
#import <QuartzCore/QuartzCore.h>

@interface POQPermissionVC ()

@end

@implementation POQPermissionVC
@synthesize  delegate, permissionPage;
NSString *permissionType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =   [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    self.view.frame = self.parentViewController.view.frame;
    
    //    self.tabBarItem.title = @"YOUR VIEW NAME";
    //    self.title = nibNameOrNil; //
    //    VCName = nibNameOrNil;
    //    [self.view.center = self.view.superview.center];
//    NSLog(@"initWithNibName POQPermissionVC");
//    
//    
//    CGRect newFrame = self.view.superview.frame;
//    newFrame.size.width -= 40;
//    newFrame.size.height -= 40;
//    newFrame.origin.x = 20;
//    newFrame.origin.y = 20;
//    self.view.frame = newFrame;
    return self;
}

- (void)dismissMyView {
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.vwFB setHidden:true];
    if ([permissionPage isEqualToString: @"Loca"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm locatie.png"]];
        [self.btnAccept setTitle:@"Deel Locatie" forState:UIControlStateNormal];
        self.txtPermission.text = @"Deel je locatie, dan kunnen we jouw buurt tonen.";
    } else if ([permissionPage isEqualToString: @"Notif"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm notificaties.png"]];
        [self.btnAccept setTitle:@"Sta Toe" forState:UIControlStateNormal];
        self.txtPermission.text = @"De Poq chat werkt alleen goed als je notificaties aan hebt staan.";
    } else if ([permissionPage isEqualToString: @"FB"]) {
        //[self.btnAccept setTitle:@"Inloggen Via FB" forState:UIControlStateNormal];
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm facebook.png"]];
        self.txtPermission.text = @"Laat zien wie je bent en meld je aan via Facebook.";
        [self.vwFB setHidden:false];
        [self.btnAccept setTranslatesAutoresizingMaskIntoConstraints:YES];
        //        CGRect frmBtn = CGRectMake(0, 250, 150, 60);
        //        [self.btnAccept setFrame:frmBtn];
        //        [self.btnAccept.titleLabel setBackgroundColor:[UIColor clearColor]];
        //        self.btnAccept.backgroundColor = [UIColor clearColor];
        [self.btnAccept setContentMode:UIViewContentModeScaleAspectFill];
        //        [self.btnAccept setImage:[UIImage imageNamed:@"LKMP7.png" ] forState:UIControlStateNormal];
        
    } else if ([permissionPage isEqualToString: @"Invite"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm invite.png"]];[self.btnAccept setTitle:@"Uitnodigen" forState:UIControlStateNormal];
        self.txtPermission.text = @"Nodig je vrienden uit voor Poq. Hoe meer zielen hoe meer vreugd!";
    }
    self.btnAccept.layer.cornerRadius = 10; // this value vary as per your desire
    self.btnAccept.clipsToBounds = YES;
    self.btnDecline.layer.cornerRadius = 10; // this value vary as per your desire
    self.btnDecline.clipsToBounds = YES;
    self.btnDecline.layer.borderWidth = 2.0f;
//    self.btnAccept.layer.borderWidth = 2.0f;
    [self.btnDecline.layer setBorderColor:[UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.9].CGColor];
}

- (void)viewDidAppear:(BOOL)animated{
   
}
- (void) viewWillAppear:(BOOL)animated{
    //    [self.btnAccept setImage:nil forState:UIControlStateNormal];
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAccept:(id)sender {
    [[self delegate] poqPermissionVCDidDecide:YES withVC:self];
}

- (IBAction)btnDecline:(id)sender {
    NSLog(@"btnDecline");
//    [self.vwTypeLogo setImage:[UIImage imageNamed: @"Jan Cremer-498x500.jpg"]];
    //register event
    [[self delegate] poqPermissionVCDidDecide:NO withVC:self];
    //    [self dismissMyView];
}


@end
