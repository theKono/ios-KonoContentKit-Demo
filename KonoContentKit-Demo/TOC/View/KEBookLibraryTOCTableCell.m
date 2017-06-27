//
//  KEBookLibraryTOCTableCell.m
//  Kono
//
//  Created by Kono on 2016/7/14.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEBookLibraryTOCTableCell.h"
#import "KEColor.h"

@implementation KEBookLibraryTOCTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIView *selectionBackgroundView = [[UIView alloc] init];
    selectionBackgroundView.backgroundColor = [KEColor konoBackgroundHighlightGray];
    self.selectedBackgroundView = selectionBackgroundView;
    
    self.articleCoverImage.layer.cornerRadius = 2.0;
    self.articleCoverImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupDescriptionWithMultiMedia:(BOOL)hasMultiMedia hasTranslation:(BOOL)hasTranslation {
    
    self.articleMediaTag.hidden = !hasMultiMedia;
    
    if (hasMultiMedia && hasTranslation) {
        
        self.articleDescriptionTag1.text = @"Multimedia";
        self.articleDescriptionTag1.textColor = [UIColor colorWithRed:144.0/255 green:144.0/255 blue:144.0/255 alpha:1];
        self.articleDescriptionTag1.hidden = NO;
        
        self.articleDescriptionTag2.text = @"中譯";
        self.articleDescriptionTag2.textColor = [UIColor colorWithRed:0/255 green:160.0/255 blue:233.0/255 alpha:1];
        self.articleDescriptionTag2.hidden = NO;
        
    } else if (hasMultiMedia) {
        
        self.articleDescriptionTag1.text = @"Multimedia";
        self.articleDescriptionTag1.textColor = [UIColor colorWithRed:144.0/255 green:144.0/255 blue:144.0/255 alpha:1];
        self.articleDescriptionTag1.hidden = NO;
        
        self.articleDescriptionTag2.hidden = YES;
        
    } else if (hasTranslation) {
        
        self.articleDescriptionTag1.text = @"中譯";
        self.articleDescriptionTag1.textColor = [UIColor colorWithRed:0/255 green:160.0/255 blue:233.0/255 alpha:1];
        self.articleDescriptionTag1.hidden = NO;
        
        self.articleDescriptionTag2.hidden = YES;
        
    } else {
        
        self.articleDescriptionTag1.hidden = YES;
        self.articleDescriptionTag2.hidden = YES;
        
    }
}

@end
