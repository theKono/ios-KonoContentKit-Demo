//
//  KELibraryBookCell.h
//  Kono
//
//  Created by Neo on 2/21/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum KEIssueCoverTagType : NSUInteger {
    KEIssueCoverTagTypeNew = 0,
    KEIssueCoverTagTypeTranslation = 1,
    KEIssueCoverTagTypeBoth = 2
} KEIssueCoverTagType;

@class KELibraryBookCell;

@interface KELibraryBookCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediaTag;

@property (weak, nonatomic) IBOutlet UIImageView *tagBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *firstTag;
@property (weak, nonatomic) IBOutlet UIImageView *secondTag;

@property (weak, nonatomic) IBOutlet UILabel *issueLabel;
@property (weak, nonatomic) IBOutlet UIView *readingProgressBase;
@property (weak, nonatomic) IBOutlet UIView *readingProgressValue;


- (void)setupTagImage:(KEIssueCoverTagType)type;

@end
