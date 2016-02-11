//
//  TabBarController.m
//  poq2 layout experiment
//
//  Created by Jeroen Dunselman on 29/01/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray* titleKeys = [NSArray arrayWithObjects:@"top places",
                          @"localizablekey1",
                          @"localizablekey2",
                          @"localizablekey3",@"localizablekey5",
                          nil];
    [super viewWillAppear:animated];
    int count = 0; for (UIViewController* viewController in self.viewControllers){
//        viewController.tabBarItem.title = NSLocalizedString([titleKeys objectAtIndex:count++], nil);
        viewController.tabBarItem.image = [UIImage imageNamed:@"virm_l.png"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
