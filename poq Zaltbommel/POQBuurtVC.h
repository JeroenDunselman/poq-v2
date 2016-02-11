//
//  POQBuurtVC.h
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 07/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//
#import "MapKit/MapKit.h"
#import <UIKit/UIKit.h>
#import "POQLocationVC.h"
@interface POQBuurtVC : UIViewController <POQLocationVCDelegate>
//<UITableViewDataSource, UITableViewDelegate>
{
IBOutlet MKMapView *worldView;
}
@property (weak, nonatomic) IBOutlet UIView *vwBuurtLoca;
@property (weak, nonatomic) IBOutlet UIView *vwData;
@property (weak, nonatomic) IBOutlet MKMapView *vwMap;

@end
