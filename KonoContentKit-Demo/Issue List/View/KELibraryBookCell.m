//
//  KELibraryBookCell.m
//  Kono
//
//  Created by Neo on 2/21/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KELibraryBookCell.h"

@implementation KELibraryBookCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CALayer *cellLayer = self.layer;
    [cellLayer setCornerRadius:2.0];
    [cellLayer setMasksToBounds:YES];
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.coverImageView.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(2.0, 2.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.coverImageView.layer.mask = shape;
    
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
}


- (void)setupTagImage:(KEIssueCoverTagType)type {
    
    UIImage *newTagImage;
    UIImage *translationTagImage;
    
    if (DEVICE_IS_IPAD) {
        newTagImage = [UIImage imageNamed:@"new_issue_tag_ipad"];
        translationTagImage = [UIImage imageNamed:@"translation_tag_ipad"];
    } else {
        newTagImage = [UIImage imageNamed:@"new_issue_tag_iphone"];
        translationTagImage = [UIImage imageNamed:@"translation_tag_iphone"];
    }
    
    switch (type) {
        case KEIssueCoverTagTypeNew: {
            self.firstTag.image = newTagImage;
        }
            break;
        case KEIssueCoverTagTypeTranslation: {
            self.firstTag.image = translationTagImage;
        }
            break;
        case KEIssueCoverTagTypeBoth: {
            self.firstTag.image = translationTagImage;
            self.secondTag.image = newTagImage;
        }
            break;
        default:
            break;
    }
    
}

@end
