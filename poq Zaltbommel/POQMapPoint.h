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
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)title pointType:(NSString *)type avatarPath:(NSString *)path;
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)title pointType:(NSString *)type avatarImage:(UIImage *)imgAvatar;
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pointType;
@property (nonatomic, copy) NSString *pathAvatar;//moet userID worden
@property (nonatomic, copy) UIImage *imgAvatar;//niet gebruiken
@property (nonatomic, readwrite) BOOL imgAvatarAvailable;
@end
