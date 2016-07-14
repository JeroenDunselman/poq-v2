//
//  POQActie.m
//  Poq
//
//  Created by Jeroen Dunselman on 04/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQActie.h"
#import "POQPromo.h"
#import "POQRequestStore.h"
//@interface POQActie()
//@property (nonatomic, retain) UIImage *theActiePromoImg;
//@end
@implementation POQActie
@dynamic actiePromoID,
actieAmbaID,
actieClaimantID,
actieTijdslot;//, actieTestTeller, theActiePromoImg;//parse: "PromoHTML"; "ProductImage"

+ (NSString *)parseClassName
{
    return @"POQActie";
}
UIImage *theActiePromoImg;
POQPromo *myPromo;
int counter;

- (UIImage *)actiePromoImage
{
    return nil;
//    self.actieTestTeller ++;
//    NSLog(@"actieTestTeller: %d", self.actieTestTeller);
//    counter ++;
//    NSLog(@"counter: %d", counter);
//    NSLog(@"actiePromoImage:%@", self.actiePromoID);
//    if (theActiePromoImg) {
//        NSLog(@"actiePromoImage was set for:%@", self.actiePromoID);
//        return theActiePromoImg;
//       // [myPromo promoImage];
//    } else {
//        UIImage *result = nil;
//        NSLog(@"actiePromoImage sought:%@", self.actiePromoID);
//        for (POQPromo *aPromo in [[POQRequestStore sharedStore] localPromos]) {
//            NSLog(@"actiePromoImage compared:%@", aPromo.objectId);
//            if ([aPromo.objectId isEqualToString:self.actiePromoID]) {
//                NSLog(@"actiePromoImage found:%@", self.actiePromoID);
//                result = aPromo.promoImage;
////            self.theActiePromoImg = result;
////                myPromo = aPromo;
//                break;
//            }
//        }
//        return result;
//    }
}

@end
