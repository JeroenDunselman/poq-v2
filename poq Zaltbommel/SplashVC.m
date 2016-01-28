//
//  SplashVC.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 15/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//
#import "SplashVC.h"

@interface SplashVC ()

@end

@implementation SplashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIView *view = self.view;
    NSString *resourceName = @"Poq logo animatie.m4v";
    NSString* movieFilePath = [[NSBundle mainBundle]
                               pathForResource:resourceName ofType:nil];
    NSAssert(movieFilePath, @"movieFilePath is nil");
    NSURL *fileURL = [NSURL fileURLWithPath:movieFilePath];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:fileURL];
    AVPlayerViewController *playerViewController =
    [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
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
