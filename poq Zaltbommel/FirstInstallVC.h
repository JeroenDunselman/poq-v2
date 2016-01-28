//
//  FirstInstallVC.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 28/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>

@interface FirstInstallVC : UIViewController
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) void *testLog;
@property (nonatomic) void *loginLayer;
@end
