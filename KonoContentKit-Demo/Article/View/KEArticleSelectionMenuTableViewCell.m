//
//  KEArticleSelectionMenuTableViewCell.m
//  Kono
//
//  Created by Kono on 2016/7/14.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleSelectionMenuTableViewCell.h"
#import "KEColor.h"

@implementation KEArticleSelectionMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIView *selectionBackgroundView = [[UIView alloc] init];
    selectionBackgroundView.backgroundColor = [KEColor konoBackgroundHighlightGray];
    self.selectedBackgroundView = selectionBackgroundView;
    
    
    if( DEVICE_IS_IPAD ){
        [self.selectionMenuArticleTitle setFont:[UIFont systemFontOfSize:20]];
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
