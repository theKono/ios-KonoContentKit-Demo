//
//  KEArticleToolMenuFontTableViewCell.h
//  Kono
//
//  Created by Kono on 2016/9/5.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KEArticleToolFontSizeCellDelegate <NSObject>

- (void)slideFontSizeController:(NSInteger)fontSize;

@end



@interface KEArticleToolMenuFontTableViewCell : UITableViewCell

@property (nonatomic, weak) id<KEArticleToolFontSizeCellDelegate> delegate;
@property (strong, nonatomic)UISlider *adjustBar;

@property (weak, nonatomic) IBOutlet UILabel *adjustLabel;

@end
