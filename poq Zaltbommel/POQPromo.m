//
//  POQPromo.m
//  Poq 
//
//  Created by Jeroen Dunselman on 04/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQPromo.h"
#import "POQRequestStore.h"
@implementation POQPromo
@dynamic promoImg, promoHTML; //parse: "PromoHTML"; "ProductImage"
#pragma getters and setters
UIImage *theImg;
+ (NSString *)parseClassName
{
    return @"POQPromo";
}

- (BOOL) AdvertisedByCurrentUser{
//    (actie met deze promoId, currentuser als AmbaId en ClaimantId is leeg)
    return ![[POQRequestStore sharedStore] getPromoActionableStatusWithId:[self objectId]];
}
//- (UIImage *)promoImageAsync{
//    if (theImg != nil) {
//        return theImg;
//    }
//    
//    PFFile *imageFile = [self objectForKey:@"promoImg"];//self.promoImg; //object[@"imageFile"];
//    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//     if (!data) {
//         return NSLog(@"%@", error);
//     }
//    theImg = [UIImage imageWithData:data];
//    }];
//   return theImg;
//}

// get a photo from me, synchronously
- (UIImage *) promoImage
{
    PFFile *f = [self objectForKey:@"promoImg"];
//    if (self.promoImg) { //_foto
//        return theImg;//self.promoImg; //_foto
//    } else if ((f = [self objectForKey:@"promoImg"])) {
        NSData *data = [f getData];
        UIImage *image = [UIImage imageWithData:data];
        theImg = image;
        return image;
//    } else {
//        return nil;
//    }
//    return  nil;
}


// get a photo from Parse asynchronously and deliver it in the block
- (void) fotoWithBlock:(POQImageBlock)block
{
    PFFile *aFile = [self objectForKey:@"promoImg"];
    if (aFile) {
        [aFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *image = nil;
            if (!error) {
                image = [UIImage imageWithData:imageData];
            }
            block(image);
        }];
    }
}

@end
