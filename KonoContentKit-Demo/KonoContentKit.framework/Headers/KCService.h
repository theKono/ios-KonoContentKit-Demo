/**
 @file KCService.h
 
 @brief
 In the Kono Content data layer famework( We name as KonoContentKit), we use this file(KCService) as an API public interface. We expect all user integrate our framework with their application could get their content simply through the function defined here.

 From our content server database schema, using top-down approach.
 
 We can own several libraries, for each library, we can set [1-many] categories. 
 For each category, we can list [1-many] titles. 
 Each title would have [1-many] issues(presenting by KCBook object in this framework). 
 Each issue contains [1-many] articles(presenting by KCBookArticle object in this framework).
 And Each article would have [1-many] pages(presenting by KCBookPage in this framework)
 
 Only the function which can get content resource need additional token and decrypt operation.
 We also support basic maintaining dowloaded bundle function in this framework.
 
 
 @author kuokuo
 @copyright  © 2017 Kono. All rights reserved.
 */
//
//  KCService.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/7.
//  Copyright © 2017年 Kono. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCBook.h"
#import "KCBookArticle.h"

/**
 @typedef KCImageSize
 @brief Types of query image size scale
 */

typedef enum KCImageSize : NSUInteger{
    
    /** 300px as the largest value of the image */
    KCImageSizeSmall = 0,
    
    /** 700px as the largest value of the image */
    KCImageSizeMedium = 1,
    
    /** original image size */
    KCImageSizeDefault = 2
    
}KCImageSize;


/**
 @typedef KCImageCropMode
 @brief Types of query image crop mode
 */
typedef enum KCImageCropMode : NSUInteger{
    
    /** image would be cropped by 1:1 ratio */
    KCImageCropModeSquare = 0,
    
    /** image would be cropped by 4:3 ratio */
    KCImageCropMode4To3 = 1,
    
    /** image would be cropped by 9:5 ratio */
    KCImageCropMode9To5 = 2,
    
    /** image won't be cropped */
    KCImageCropModeDefault = 3
    
}KCImageCropMode;

/**
 
 @class KCService
 
 @brief The public interface for integrated application to access Kono content server
 
 @remark This class is designed and implemented to help developer to get content deployed by KPP solution. This class act as a black box for the API communication and API return value processing and parsing.
 
*/
@interface KCService : NSObject

#pragma mark - property

/** @brief This instance is a singleton object, which maintain all content related service interface 
 */
+ (KCService *) contentManager;


// use fake function for login
- (void)loginTestingUser:(void (^)(void ))completeBlock;

#pragma mark - book warehouse top-level function

/**
 Calling API to fetch all books information dictionary for target title.
 
 @param titleID 
 The target title ID string to request.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: book array, which contains book info dictionary for KCBook object.
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getAllBooksForTitleID:(NSString *)titleID complete:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;



/**
 Calling API to fetch KCBook list for given title ID and year.
 
 @param titleID
 A string as parameter to query Kono content server the KCBook belongs to this title.
 
 @param year
 A string as parameter to query Kono content server the KCBook belongs to this year.
 
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: category array, which contains category object.
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */

- (void)getAllBooksForTitleID:(NSString *)titleID forYear:(NSString *)year complete:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;



/**
 Calling API to fetch category list.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: category array, which contains category object.
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 @code
 Category object example: @{@"id":{category_id},
                        @"name":{category_name},
                        @"is_adult":{category_adult_property},
                        @"dict_key":{category_localization_key},
                        @"library":{category_belong_libraryname}}
 @endcode
 */
- (void)getAllCategories:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to fetch title list.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the title array consist of title string
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getAllTitles:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;



/**
 Calling API to fetch year list of which year contains accessable books.
 
 @param titleID
 A string value for the title ID to query which year contains books
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the year array consist of year dictionary 
     Such as:@[@"year":@"2017",@"year":@"2016"]
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getAllYearsContainBooksForTitleID:(NSString *)titleID complete:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to fetch all latest books of its title of certain category.
 
 @param categoryID 
 The target category ID string to request.
 
 @param completeBlock 
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the book array consist of latest book of all titles belong to target category
 Such as:@[book1_InfoDic,book2_InfoDic], book Info Dictionary consist of all book attributes we needed for creating KCBook object

 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getLatestBookForCategoryID:(NSString *)categoryID complete:(void (^)(NSArray *))completeBlock fail:(void (^)(NSError *))failBlock;


- (void)getLatestBookForTitleID:(NSString *)titleID complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;

// individual book related function


#pragma mark - book warehouse individual book related function

/**
 Calling API to fetch all articles given a KCBook object, we will parsed all articles information and keep in the given KCBook object property
 
 @param book 
 The target KCBook object we need to get the book detail information
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the book object which we have generate articleArray and pageMappingArray according to API return value
 
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getAllArticlesForBook:(KCBook *)book complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to get a KCBook object with given bookID, we will parsed the book basic information without content asset
 
 @param bookID
 The target KCBook ID we want to get
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the book object which we get the book attribute which can be used for render layout. 
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getBookForBookID:(NSString *)bookID complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to fetch KCBook bundle, and we can use the bundle to present the book content in offline environment
 
 @param book 
 The target KCBook object we need to get the book bundle
 
 @param progressBlock
 A block object to be executed when the download task get new data. This block will be executed multiple times, we mostly use it to update UI of download progress.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the book bundle file path string, which we can get the book content through this file path
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getBundleForBook:(KCBook *)book progress:(void (^)(CGFloat progress))progressBlock complete:(void (^)(NSString *))completeBlock fail:(void (^)(NSError *))failBlock;

/**
 Calling API to fetch KCBook particular page html5 asset,  we will download a zip file from content server, then unzip, decrypt to create a folder which contains the HTML, image, svg files for webview to render.

 
 @param page
 The KCBookPage object, which will contain the page information including bookID, page number and articlesArray we will use in the API call.
 
 @param progressBlock
 A block object to be executed when the download task get new data. This block will be executed multiple times, we only monitor the progress of downloading zip file and ignore the decrypt and unzip action.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page HTML file path, which we can load this HTML file with native webview (UIWebview or WKWebview are all avaiable)
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getPageHTMLForBookPage:(KCBookPage *)page progress:(void (^)(CGFloat progress))progressBlock complete:(void (^)(NSString *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to fetch KCBook thumbnail, we will get an array contains each book page thumbnail image path URL and fulfill the URL into the KCBook pageMapping array object (KCBookPage)
 
 @param book
 The target KCBook object we need to get thumbnail images path
 
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the book with a parsed pageMappingArray consist of KCBookPage objects. KCBookPage would store the thumbnail image file URL.
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getThumbnailForBook:(KCBook *)book complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;



#pragma mark - book warehouse individual article related function

/**
 Calling API to get specific KCBookArticle access token(also can be viewed as article key with expiring date)
 
 @param article
 The target KCBookArticle object we need its access token
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the article with article key, which we manage by KCBookArticleKey class ( contains expire time and access token)
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getAccessKeyForArticle:(KCBookArticle *)article complete:(void (^)(KCBookArticle *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to get specific KCBookArticle information
 
 @param articleID
 The target article ID we want to get
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the KCBookArticle object, which has been parsed all article attribute but without article asset
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getArticleForArticleID:(NSString *)articleID complete:(void (^)(KCBookArticle *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Calling API to get specific KCBookArticle content text, we passing by JSON format
 
 @param article
 The target KCBookArticle object we need its article content with JSON format
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the article with articleTextData, which we operate with NSData datastructure. If we want to get the JSON formate, we can use native NSJSONSerialization function
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 @code 
 NSDictionary *articleJSON = [NSJSONSerialization JSONObjectWithData:article.articleTextData options:kNilOptions error:&error];
 @endcode
 */
- (void)getArticleTextForArticle:(KCBookArticle *)article complete:(void (^)(NSData *))completeBlock fail:(void (^)(NSError *))failBlock;



/**
 Calling API to get specific article page content with HTML format.
 In order to get HTML file, we will download a zip file from content server, then unzip, decrypt to create a folder which contains the HTML, image, svg files for webview to render.
 
 @param article
 The article contains the target page we need content with HTML format
 
 @param offset
 The page offset in its article. Example: A page number 60, it belong to the article contains page [59, 60, 61]. The offset would be "1" here.
 
 @param progressBlock
 A block object to be executed when the download task get new data. This block will be executed multiple times, we only monitor the progress of downloading zip file and ignore the decrypt and unzip action.
 
 @param completeBlock
 A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page HTML file path, which we can load this HTML file with native webview (UIWebview or WKWebview are all avaiable)
 
 @param failBlock
 A block object to be executed when the network task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the error describing which error we encounter
 
 */
- (void)getArticlePageHTMLForArticle:(KCBookArticle *)article withOffset:(NSInteger)offset progress:(void (^)(CGFloat progress))progressBlock complete:(void (^)(NSString *))completeBlock fail:(void (^)(NSError *))failBlock;


#pragma mark - local book bundle operation function

/**
 Each time we download KCBook bundle through this SDK, we have default bundle file path. We can the the file path through bookID.
 
 @param bookID
 The bookID we want its default bundle file path.
 
 @return
 The default bundle file path string we keep for bookID.
 
 */
- (NSString *)getBookBundleFilePathForBookID:(NSString *)bookID;


/**
 We can generate KCBook object from local bundle.
 
 @param bookID
 The article contains the target page we need content with HTML format
 
 @return
 The KCBook object with basic properties parsed from local bundle file.
 
 */
- (KCBook *)getBookFromBundleForBookID:(NSString *)bookID;



/**
 Get bookID list we have book bundle files
 
 @return
 Return bookID list array which contains bookID string object. If there is no book bundle, it will return empty array
 
 */
- (NSArray *)getBundleBookIDList;


/**
 Get book cover image file path within book bundle.
 
 @param bookID
 The cover image for which bookID
 
 @return
 The file path string stored cover image
 
 */
- (NSString *)getCoverImagePathFromBundleForBookID:(NSString *)bookID;



/**
 Parse article array and pageMapping array for the target KCBook from book bundle.
 The article array and pageMapping array could be generated through toc.json file in the bundle directory.
 
 @param book
 The KCBook object which we want to update its property from local book bundle.
 
 @param completeBlock
 A block object to be executed after the parsing code is done without error. This block has no return value and takes one argument: the book object which we have generate articleArray and pageMappingArray according to local bundle file
 
 @param failBlock
 A block object to be executed when the parsing task finishes unsuccessfully, it could be the toc.json file within target bundle directory not existed or damaged.
 
 */
- (void)getAllArticlesFromBundleForBook:(KCBook *)book complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;


/**
 Get the page content with HTML format from local bundle directory. We need to reach correct file path and decrypt, unzip it from local bundle. The decrypt secret need to be set in KCServerConfig.
 
 @param bookID
 The page bookID, we will use it to get the bundle file path and the HTML encrypted file.
 
 @param pageNo
 The page number of which HTML content file we want to get.
 
 @param completeBlock
 A block object to be executed after the parsing code is done without error. This block has no return value and takes one argument: the HTML file path string which we can load this HTML file with native webview (UIWebview or WKWebview are all avaiable).
 
 @param failBlock
 A block object to be executed when the parsing task finishes unsuccessfully, the reason could be the local aes file decrypt error or decrypted file unzip error or the local bundle doesn't exist.
 
 */
- (void)getPageHTMLFromBundleForBookID:(NSString *)bookID withPageNumber:(NSInteger)pageNo complete:(void (^)(NSString *))completeBlock fail:(void (^)(NSError *))failBlock;



/**
 From the loacl bundle directory, we can get a directory contains each book page thumbnail image. We will fulfill the file path into the KCBook pageMapping array object (KCBookPage).
 
 @param book
 The target KCBook object we want to operate
 
 @param completeBlock
 A block object to be executed after the parsing code is done without error. This block has no return value and takes one argument:
 
 @param failBlock
 A block object to be executed when the parsing task finishes unsuccessfully, the reason could be toc.json file parsing error or the local bundle doesn't exist.
 
 */
- (void)getThumbnailFromBundleForBook:(KCBook *)book complete:(void (^)(KCBook *))completeBlock fail:(void (^)(NSError *))failBlock;

#pragma mark - image URL related function

/**
 With given {article ID、target image size、target image crop ratio}, we can get image URL for client to display.
 
 @param articleID
 ID of the article we want get it main image URL
 
 @param size
 The return image size we want. We provide small(300px)、medium(700px) and origin option.
 
 @param cropMode
 The return image crop mode we want. We provide 1:1(square)、4:3、9:5 and origin option.
 
 @return
 The URL string for article main image
 
 */
- (NSString *)articleMainImageURLForArticleID:(NSString *)articleID withSize:(KCImageSize )size withCrop:(KCImageSize)cropMode;


/**
 With given book ID and target image size, we can get image URL for client to display.
 
 @param bookID
 ID of the book we want get it cover image URL
 
 @param size
 The return image size we want. We provide small(300px)、medium(700px) and origin option.
 
 @return
 The URL string for book cover image
 
 */
- (NSString *)bookCoverImageURLForBookID:(NSString *)bookID withSize:(KCImageSize )size;


/**
 With given title ID and target image size, we can get image URL for client to display.
 
 @param titleID
 ID of the title we want get it latest book cover image URL
 
 @param size
 The return image size we want. We provide small(300px)、medium(700px) and origin option.
 
 @return
 The URL string for title latest book cover image
 
 */
- (NSString *)latestBookCoverImageURLForTitleID:(NSString *)titleID withSize:(KCImageSize )size;

#pragma mark - book warehouse configuration function


/**
 Interface for setting content server base URL.
 
 @param apiURL
 The URL we want to set as content server base URL
 
 */
- (void)initializeApiURL:(NSString *)apiURL;



/**
 Interface for setting content access token. We will use this token for accessing premium content from our server.
 
 @param token
 The string we will use as the token for premium content API call request header, it should be paired with variable "accessID" in KCServerConfig, otherwise the validation would fail.
 
 */
- (void)initializeToken:(NSString *)token;



/**
 Interface for setting decrypt secret using for decryping downloaded KCBook bundle
 
 @param decryptSecret
 The string we will use to decrypt for all book bundle encypted file. Decrypt function would be used both in online API callback and local bundle file.
 
 */
- (void)initializeBundleDecryptSecret:(NSString *)decryptSecret;



/**
 Interface for setting decrypt secret using for decryping content file of HTML format. (The HTML file can be viewed as PDF file for the KCBook.)
 
 @param decryptSecret
 The string we will use to decrypt for all book page file for HTML format.  Decrypt function would be used both in online API callback and local bundle file.
 
 */
- (void)initializeHTMLDecryptSecret:(NSString *)decryptSecret;

@end
