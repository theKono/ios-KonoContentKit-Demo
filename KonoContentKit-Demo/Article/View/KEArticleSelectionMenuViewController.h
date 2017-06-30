//
//  KEArticleSelectionMenuViewController.h
//  Kono
//
//  Created by Kono on 2016/7/11.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEArticleSelectionMenuTableViewCell.h"

typedef enum KEArticleSelectionMenuType : NSUInteger{
    KEArticleSelectionMenuFitReadingType = 0,
    KEArticleSelectionMenuLikeType = 1,
    KEArticleSelectionMenuShareType = 2,
    KEArticleSelectionMenuListType = 3,
    KEArticleSelectionMenuBookmarkType = 4,
    KEArticleSelectionMenuTranslationType = 5,
    KEArticleSelectionMenuTypeCount
}KEArticleSelectionMenuType;

static int ARTICLE_MENU_TITLE_HEIGHT = 48;

static int ARTICLE_MENU_ITEM_HEIGHT = 68;
static int ARTICLE_MENU_ITEM_HEIGHT_IPAD = 72;

@interface KEArticleSelectionMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)refreshArticleMenuView;

@property (nonatomic) KEArticleSelectionMenuType displayType;

@property (nonatomic, strong)        KCBook *bookItem;

@property (nonatomic, strong)        KCBookArticle *selectedArticleItem;

@property (nonatomic, strong)        NSArray     *articleArray;

@property (nonatomic, weak)          UIViewController *parentViewController;

@property (weak, nonatomic) IBOutlet UILabel *selectionMenuTitle;

@property (weak, nonatomic) IBOutlet UITableView *selectionTable;

@end
