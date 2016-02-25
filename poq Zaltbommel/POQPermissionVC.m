//
//  POQPermissionVC.m
//  POQPermission
//
//  Created by Jeroen Dunselman on 17/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQPermissionVC.h"

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
    
}

- (void)viewDidAppear:(BOOL)animated{
   
}
- (void) viewWillAppear:(BOOL)animated{
    if ([permissionPage isEqualToString: @"Loca"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm locatie.png"]];
        [self.btnAccept setTitle:@"Deel Mijn Locatie" forState:UIControlStateNormal];
        self.txtPermission.text = @"Als we je lokatie weten, kunnen we de activiteit in jouw buurt aan je tonen en kunnen we jouw verzoeken omroepen in je buurt.";
    } else if ([permissionPage isEqualToString: @"Notif"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm notificaties.png"]];
        [self.btnAccept setTitle:@"Sta Toe" forState:UIControlStateNormal];
        self.txtPermission.text = @"Ook als poq niet in gebruik is, kun je direct op de hoogte worden gebracht van nieuwe chat berichten en verzoeken. \nOm hiervan gebruik te maken, geef je eerst toestemming voor notificaties.";
    } else if ([permissionPage isEqualToString: @"FB"]) {
        //[self.btnAccept setTitle:@"Inloggen Via FB" forState:UIControlStateNormal];
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm facebook.png"]];
        self.txtPermission.text = @"Je kunt oproepen niet anoniem sturen of ontvangen. \nDaarom vragen we je om in te loggen met je Facebook gegevens. ";
        [self.btnAccept setTranslatesAutoresizingMaskIntoConstraints:YES];
//        CGRect frmBtn = CGRectMake(0, 250, 150, 60);
//        [self.btnAccept setFrame:frmBtn];
        [self.btnAccept setContentMode:UIViewContentModeScaleAspectFill];
        [self.btnAccept setImage:[UIImage imageNamed:@"facebook knop" ] forState:UIControlStateNormal];
        
    } else if ([permissionPage isEqualToString: @"Invite"]) {
        [self.vwTypeLogo setImage:[UIImage imageNamed: @"perm invite.png"]];[self.btnAccept setTitle:@"Uitnodigen" forState:UIControlStateNormal];
        self.txtPermission.text = @"Nodig je vrienden uit voor Poq. Hoe meer zielen hoe meer vreugd!";
    }
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
