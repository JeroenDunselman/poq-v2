//
//  BNRMapPoint.m
//  WhereAmI
//
//  Created by Jeroen Dunselman on 20/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import "TAAMapPoint.h"

@implementation TAAMapPoint
@synthesize coordinate, title;
-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t
{
    //self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:t];
    }
    return self;
}
-(id)init
{
    return [self InitWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Hometown"];
}
@end
