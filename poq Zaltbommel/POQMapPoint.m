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
-(UIImage *) imgForType
{
    NSString *theType = self.pointType;
    NSArray *items = @[@"home", @"poquser", @"poqRqstSupply", @"poqRqstDemand", @"poqRqstCancelled"];
    NSUInteger item = [items indexOfObject:theType];
    UIImage *theImg;
    switch (item) {
        case 0:
            theImg = [UIImage imageNamed:@"home anno.png"];
            break;
        case 1:
            theImg = [UIImage imageNamed:@"user anno.png"];
            break;
        case 2:
            theImg = [UIImage imageNamed:@"exclamation.png"];
            break;
        case 3:
            theImg = [UIImage imageNamed:@"question.png"];
            break;
        case 4:
            theImg = [UIImage imageNamed:@"check.png"];
            break;
        default:
            theImg = [UIImage imageNamed:@"refresh home loca.png"];
    }
    return theImg;
}

-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc
{
    //self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:desc];
    }
    return self;
}

-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc pointType:(NSString *)pType
{
    //self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:desc];
        [self setPointType:pType];
    }
    return self;
}

-(id)init
{
    return [self InitWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Hometown"];
}
@end
