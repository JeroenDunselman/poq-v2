//
//  BNRMapPoint.h
//  WhereAmI
//
//  Created by Jeroen Dunselman on 20/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@interface POQMapPoint : NSObject <MKAnnotation>
{}
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)title;
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)title pointType:(NSString *)type;
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pointType;
@end
