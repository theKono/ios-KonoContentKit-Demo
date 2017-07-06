//
//  KEMainViewController.h
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/7/6.
//  Copyright © 2017年 kono. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum KETabItemIndex : NSUInteger {
    
    KETabItemView = 0,
    KETabItemRawData = 1,
    
} KETabItemIndex;

@interface KEMainViewController : UITabBarController

@end
