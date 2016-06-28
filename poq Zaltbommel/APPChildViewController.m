//
//  APPChildViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPChildViewController.h"

@interface APPChildViewController ()

@end

@implementation APPChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%d", self.index];
    
    
    NSString *fullURL =    @"http://www.poqapp.nl";
    if (self.index == 0) {
        fullURL = @"http://www.poqapp.nl/#!spelregels/rvm95";
    } else if (self.index == 0) {
        fullURL = @"http://www.poqapp.nl/#!faq/kj830";
    }
    
//        NSURL *url = [ [ NSURL alloc ] initWithString: @"http://poqapp.nl/#!uitleg/cctor" ];
//    //
//    NSString *anURL = @"https://www.google.nl/search?client=safari&rls=en&q=https:+//youtu.be/IoIcwZAG1DY%3Ft=1h22m44s&ie=UTF-8&oe=UTF-8&gfe_rd=cr&ei=_rwbV6ikGerG8Af9tYGYAg";
//    NSString *anURL = @"http://poqapp.nl/#!uitleg/cctor";
    
    NSURL *url = [NSURL URLWithString:fullURL];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.theWebView loadRequest:requestObj];
//    [self.theWebView setFrame:self.accessibilityFrame];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
