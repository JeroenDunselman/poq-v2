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
    NSArray* titleKeys = [NSArray arrayWithObjects:@"Acties",
                          @"Buurt",
                          @"Gesprekken",
                          @"Uitnodigen",@"localizablekey5",
                          nil];
    NSArray* imgKeys = [NSArray arrayWithObjects:@"Screen Shot 2016-06-27 at 15.43.21",
                          @"Wall",
                          @"Chat",
                          @"Invite",@"localizablekey5",
                          nil];
    [super viewWillAppear:animated];
    int count = 0; for (UIViewController* viewController in self.viewControllers){
        viewController.tabBarItem.title = NSLocalizedString([titleKeys objectAtIndex:count], nil);
        NSString *t = [imgKeys objectAtIndex:count++];
        viewController.tabBarItem.image = [UIImage imageNamed:t];
//        NSLog(@"%@", t);
     //                                           [imgKeys objectAtIndex:count++]];
    }
//    [[self.tabBar appearance] setBarTintColor:[UIColor redColor]];
    
}

//-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
////    UIViewController* viewController = [self.viewControllers objectAtIndex:0];
////    viewController.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
//
//    return self;
//}

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
