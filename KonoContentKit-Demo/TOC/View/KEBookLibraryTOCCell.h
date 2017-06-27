//
//  KEBookLibraryTOCCell.h
//  Kono
//
//  Created by Neo on 11/18/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEArticleViewController.h"

@class KEBookLibraryTOCCell;

@protocol KEBookLibraryTOCCellDelegate <NSObject>

- (void)clickedOnCell:(KEBookLibraryTOCCell*)cell;

@end


@interface KEBookLibraryTOCCell : UICollectionViewCell<UIScrollViewDelegate, UIGestureRecognizerDelegate>{

    UITapGestureRecognizer *_gestureReconizer;
}


@property (nonatomic, weak) id<KEBookLibraryTOCCellDelegate> delegate;

@property (nonatomic) BOOL isFree;

@property (nonatomic) BOOL isProvideMedia;

@property (nonatomic) KEArticleReadMode readMode;

@property (weak, nonatomic) IBOutlet UIImageView *articleCoverImageView;

@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *readModeTag;

@property (weak, nonatomic) IBOutlet UIImageView *mediaTag;


@end
