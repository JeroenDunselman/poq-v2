//
//  MyConversationViewController.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 12/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "MyConversationViewController.h"

@interface MyConversationViewController ()

@end

@implementation MyConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];
    
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
