//
//  BNRMapPoint.m
//  WhereAmI
//
//  Created by Jeroen Dunselman on 20/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQMapPoint.h"
#import "POQRequestStore.h"

@implementation POQMapPoint
@synthesize coordinate, title, pointType, imgAvatarAvailable;
NSMutableDictionary *theDict;

-(UIImage *) imgAvatar {
//    NSObject *avatar = theDict[self.pathAvatar] ;
    if (!theDict[self.pathAvatar]){ //() {r
        return [self imgForType];
    } else {
        if(![self imgAvatarAvailable]){
            return [self imgForType];
        } else {
            return theDict[self.pathAvatar];
        }
    }
}

-(BOOL) imgAvatarAvailable{
    if([theDict[self.pathAvatar] isKindOfClass:[UIImage class]]){
        return true;
    } else {
        return false;
    }
}

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
            theImg = [UIImage imageNamed:@"Aanbod"];//]@"exclamation.png"];
            break;
        case 3:
            theImg = [UIImage imageNamed:@"Vraag"];//question.png"];
            break;
        case 4:
            theImg = [UIImage imageNamed:@"CancelledRequest"];//check.png"];
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
//    self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:desc];
        [self setPointType:pType];
    }
    return self;
}

-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc pointType:(NSString *)pType avatarPath:(NSString *)path
{
    //    self = [super init];
    if (self) {
        [self initTheDict];
        coordinate = c;
        [self setTitle:desc];
        [self setPointType:pType];
        [self setPathAvatar:path];
    }
    return self;
}

-(id)InitWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)desc pointType:(NSString *)pType avatarImage:(UIImage *)imgAvatar
{
    //    self = [super init];
    if (self) {
        [self initTheDict];
        coordinate = c;
        [self setTitle:desc];
        [self setPointType:pType];
        
        if (imgAvatar) {
            [self setImgAvatar:imgAvatar];
        } else{
            [self imgForType];
        }
    }
    return self;
}

-(id)init
{
    return [self InitWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Hometown"];
}

-(void) initTheDict{
    theDict = [[POQRequestStore sharedStore] avatars];
}

@end
