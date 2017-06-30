//
//  KEArticleToolFontSizeViewController.h
//  Kono
//
//  Created by Kono on 2016/7/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KEArticleToolFontSizeAdjustDelegate <NSObject>

- (void)slideFontSizeController:(NSInteger)fontSize;

@end



@interface KEArticleToolFontSizeViewController : UIViewController

@property (nonatomic, weak) id<KEArticleToolFontSizeAdjustDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISlider *adjustBar;

@property (weak, nonatomic) IBOutlet UILabel *adjustLabel;

@end
