//
//  AppDelegate.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <LayerKit/LayerKit.h>
#import "ViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//, LYRClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *controller;
@property (nonatomic) LYRClient *layerClient;
//@property (nonatomic, retain) dispatch_queue_t backgroundQueue;

@end

