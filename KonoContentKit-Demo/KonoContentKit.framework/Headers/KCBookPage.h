//
//  KCBookPage.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/17.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBookArticle.h"

/**
 
 @class KCBookPage
 
 @brief This class is designed for easily displaying or tracking content in integrated APP.
 
 @remark This class is designed for adding the KCBookArticle concept into each page. Also keep the thumbnail iamge file PATH(it could be online or local) in this object. KCBookPage object would be putting in pageMappingArray in KCBook. 
 */
@interface KCBookPage : NSObject

@property (nonatomic) NSInteger pageNumber;
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong) NSArray<KCBookArticle *> *articleArray;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *htmlFilePath;

@end
