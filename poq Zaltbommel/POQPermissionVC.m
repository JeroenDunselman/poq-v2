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
@synthesize  delegate;
NSString *permissionType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =   [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    self.view.frame = self.parentViewController.view.frame;
    
    //    self.tabBarItem.title = @"YOUR VIEW NAME";
    //    self.title = nibNameOrNil; //
    //    VCName = nibNameOrNil;
    //    [self.view.center = self.view.superview.center];
    NSLog(@"initWithNibName POQPermissionVC");
    CGRect newFrame = self.view.superview.frame;
    newFrame.size.width -= 40;
    newFrame.size.height -= 40;
    newFrame.origin.x = 20;
    newFrame.origin.y = 20;
    self.view.frame = newFrame;
    return self;
}

- (void)dismissMyView {
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([permissionType isEqualToString: @"locale"]) {
        self.btnAccept.titleLabel.text = @"Deel Mijn Locatie";
    } else if ([permissionType isEqualToString: @"push"]) {
        self.btnAccept.titleLabel.text = @"Bericht Me";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAccept:(id)sender {
    NSLog(@"btnAccept");
    [self.vwTypeLogo setImage:[UIImage imageNamed: @"11219680_401225856738419_3242760853956317445_n.jpg"]];
    if ([permissionType isEqualToString: @"locale"]) {
        //
    } else if ([permissionType isEqualToString: @"push"]) {
        //
    }
    [[self delegate] poqPermissionVCDidDecide:YES withVC:self];
//    [self dismissMyView];
}

- (IBAction)btnDecline:(id)sender {
    NSLog(@"btnDecline");
    [self.vwTypeLogo setImage:[UIImage imageNamed: @"Jan Cremer-498x500.jpg"]];
    //register event
    [[self delegate] poqPermissionVCDidDecide:NO withVC:self];
    //    [self dismissMyView];
}


@end
