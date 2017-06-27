//
//  KEArticleToolMenuFontTableViewCell.m
//  Kono
//
//  Created by Kono on 2016/9/5.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleToolMenuFontTableViewCell.h"
#import "KEColor.h"

static int defaultFontSizeScale = 20;

@implementation KEArticleToolMenuFontTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSInteger storeFontSizeOffset;
    
    self.adjustLabel.text = @"Font Size";
    
    self.adjustBar = [[UISlider alloc] initWithFrame:CGRectMake(23, 32, 274, 31)];
    self.adjustBar.minimumValue = 0;
    self.adjustBar.maximumValue = 1;
    self.adjustBar.userInteractionEnabled = YES;
    if( [[storage objectForKey:@"KEArticleFontSize"] isKindOfClass:[NSNumber class]]){
        storeFontSizeOffset = [[storage objectForKey:@"KEArticleFontSize"] integerValue];
        self.adjustBar.value = ((float)storeFontSizeOffset / (float)defaultFontSizeScale) + 0.5;
    }
    else{
        self.adjustBar.value = 0.5;
    }
    self.adjustBar.tintColor = [KEColor konoGreen];
    [self.adjustBar setThumbImage:[UIImage imageNamed:@"adjustBarThumbimage"] forState:UIControlStateNormal];
    [self.adjustBar setThumbImage:[UIImage imageNamed:@"adjustBarThumbimage"] forState:UIControlStateHighlighted];
    
    [self.adjustBar addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.adjustBar];
    
    
}
- (IBAction)valueChanged:(id)sender {
    
    
    NSInteger adjustFontSize = (int)(( self.adjustBar.value - 0.5 ) * (float)defaultFontSizeScale);
    
    if( [self.delegate respondsToSelector:@selector(slideFontSizeController:)]){
        [self.delegate slideFontSizeController:adjustFontSize];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
