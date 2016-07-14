//
//  POQMsg.h
//  Pods
//
//  Created by Jeroen Dunselman on 14/07/16.
//
//

#import <Parse/Parse.h>

@interface POQMsg : PFObject
@property (nonatomic, retain) NSString *msgFrom;
@property (nonatomic, retain) NSString *msgTo;
@property (nonatomic, retain) NSString *msgActieId;
@property (nonatomic, retain) NSString *msgTxt;
//@property (nonatomic, retain) NSString *actieTijdslot;

@end
