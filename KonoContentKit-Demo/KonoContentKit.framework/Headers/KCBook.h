//
//  KCBook.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/15.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBookArticle.h"
#import "KCBookPage.h"

/**
 
 @class KCBook
 
 @brief This class is define which properties we provide for a book by Kono content server.
 
 @remark This class is designed for generating KCBook object, we list all properties we can get from Kono content server. We can set these properties by a NSDictionary object. KCBook object can be mapped to the "issue" or "magazine" in Kono reading product.
 
 */
@interface KCBook : NSObject

@property (nonatomic, strong) NSString *titleID;
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong) NSDate   *publishedDate;
@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bookDescription;
@property (nonatomic, strong) NSString *year;

@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL isHasPDF;
@property (nonatomic) BOOL isHasFitreading;
@property (nonatomic) BOOL isHasAudio;
@property (nonatomic) BOOL isHasVideo;
@property (nonatomic) BOOL isAdult;
@property (nonatomic) BOOL isLeftFlip;

@property (nonatomic, strong) NSString *coverImageSmall;
@property (nonatomic, strong) NSString *coverImageMedium;
@property (nonatomic, strong) NSString *coverImageOrigin;

@property (nonatomic, strong) NSArray<KCBookArticle *> *articleArray;
@property (nonatomic, strong) NSArray<KCBookPage *> *pageMappingArray;


- (id)initBookFromDictionary:(NSDictionary *)dic;


@end
