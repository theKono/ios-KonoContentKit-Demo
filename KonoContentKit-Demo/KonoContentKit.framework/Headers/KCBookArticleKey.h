//
//  KCBookArticleKey.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/23.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 @class KCBookArticleKey
 
 @brief This class pack the KCBookArticle access token and the expireDate to a single object.
 
 @remark This class is designed for supporting KCBookArticle object. If we want to get KCBookArticle content, we must have access token. According to accessing ID authority and KCBookArticle selling status, we may or may not get the access token. Also, by Kono content server setting, each access token would have limited using time for content accessing control.
 
 */
@interface KCBookArticleKey : NSObject

@property (nonatomic, strong) NSDate   *expireDate;
@property (nonatomic, strong) NSString *token;

@end
