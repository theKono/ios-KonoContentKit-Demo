//
//  KCServerConfig.h
//  KonoContentKit
//
//  Created by kuokuo on 2017/3/17.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 
 @class KCServerConfig
 
 @brief This class keep information to communicate Kono content server. We keep the setter and getter method as class method.
 
 @remark This class is designed for keep basic information to communicate Kono content server and decrypt the data retrieved from Kono content server.
 
 */
@interface KCServerConfig : NSObject

// Get config function
+ (NSString*)getAccessID;

+ (NSString*)getAccessToken;

+ (NSString*)getApiBaseURL;

+ (NSString*)getContentOwnerID;

+ (NSString*)getBundleDecryptSecret;

+ (NSString*)getHTMLDecryptSecret;

// Set config function
+ (void)setAccessID:(NSString*)accessID;

+ (void)setAccessToken:(NSString*)accessToken;

+ (void)setApiBaseURL:(NSString*)newApiURL;

+ (void)setContentOwnerID:(NSString*)contentOwnerID;

+ (void)setBundleDecryptSecret:(NSString*)newBundleDecryptSecret;

+ (void)setHTMLDecryptSecret:(NSString*)newHTMLDecryptSecret;

@end
