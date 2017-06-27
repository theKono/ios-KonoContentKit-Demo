//
//  KCBookArticle.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/20.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBookArticleKey.h"

/**
 
 @class KCBookArticle
 
 @brief This class is define which properties we provide for an article by Kono content server.
 
 @remark This class is designed for generating KCBookArticle object, we list all properties we can get from Kono content server. We can set these properties by a NSDictionary object. Each KCBookArticle must belong to certain KCBook. KCBookArticle object can be mapped to the "article" in Kono reading product.
 
 */
@interface KCBookArticle : NSObject


@property (nonatomic, strong) NSString *articleID;
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong) NSDate   *publishedDate;
@property (nonatomic, strong) NSString *articleTitle;
@property (nonatomic, strong) NSString *articleDescription;
@property (nonatomic, strong) NSString *articleIntro;
@property (nonatomic, strong) KCBookArticleKey *accessKey;

@property (nonatomic) NSInteger beginAt;
@property (nonatomic) NSInteger endAt;
@property (nonatomic, readonly) NSInteger numberOfPages;

@property (nonatomic) BOOL isHasPDF;
@property (nonatomic) BOOL isHasFitreading;
@property (nonatomic) BOOL isHasAudio;
@property (nonatomic) BOOL isHasVideo;
@property (nonatomic) BOOL isAvailabe;

@property (nonatomic, strong) NSDictionary *mainImageOriginalGroup;
@property (nonatomic, strong) NSDictionary *mainImageCropSquareGroup;
@property (nonatomic, strong) NSDictionary *mainImageCrop4To3Group;
@property (nonatomic, strong) NSDictionary *mainImageCrop9To5Group;

@property (nonatomic, strong) NSString *largeMainImageURL;
@property (nonatomic, strong) NSString *mediumMainImageURL;
@property (nonatomic, strong) NSString *smallMainImageURL;

@property (nonatomic, strong) NSData *articleTextData;

- (id)initArticleFromDictionary:(NSDictionary *)dic;

@end
