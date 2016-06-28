//
//  PoqPromoTVC.h
//  Poq 
//
//  Created by Jeroen Dunselman on 27/06/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol POQPromoTVCDelegate <NSObject>
@end
@interface POQPromoTVC : UITableViewController{
    id <POQPromoTVCDelegate> delegate;
}
@property (retain) id delegate;
@end
