//
//  KENewFitReadingViewController.h
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/9/5.
//  Copyright © 2017年 kono. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum KEOperateButtonType : NSUInteger{
    KEOperateButtonTypePlay = 0,
    KEOperateButtonTypeStop = 1,
    KEOperateButtonTypePrevious = 2,
    KEOperateButtonTypeNext = 3
    
}KEOperateButtonType;

@interface KENewFitReadingViewController : UIViewController

@property (nonatomic, strong) KCBook *bookItem;
@property (nonatomic, strong) KCBookArticle *articleItem;


@end
