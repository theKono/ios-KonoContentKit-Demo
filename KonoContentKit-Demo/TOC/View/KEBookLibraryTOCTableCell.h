//
//  KEBookLibraryTOCTableCell.h
//  Kono
//
//  Created by Kono on 2016/7/14.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEBookLibraryTOCTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *articleCoverImage;

@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;

//ipad only
@property (weak, nonatomic) IBOutlet UILabel *articleIntroText;

@property (weak, nonatomic) IBOutlet UILabel *articleChargeTag;
@property (weak, nonatomic) IBOutlet UILabel *articleReadModeTag;
@property (weak, nonatomic) IBOutlet UILabel *articleDescriptionTag1;
@property (weak, nonatomic) IBOutlet UILabel *articleDescriptionTag2;
@property (weak, nonatomic) IBOutlet UIImageView *articleMediaTag;

- (void)setupDescriptionWithMultiMedia:(BOOL)hasMultiMedia hasTranslation:(BOOL)hasTranslation;

@end
