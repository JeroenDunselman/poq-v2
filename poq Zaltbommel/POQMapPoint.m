//
//  BNRMapPoint.m
//  WhereAmI
//
//  Created by Jeroen Dunselman on 20/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQMapPoint.h"

@implementation POQMapPoint
@synthesize coordinate, title, pointType;
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc
{
    //self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:desc];
    }
    return self;
}

-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc pointType:(NSString *)type
{
    //self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:desc];
        [self setPointType:type];
    }
    return self;
}

-(id)init
{
    return [self InitWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Hometown"];
}
@end
