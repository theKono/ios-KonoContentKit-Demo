//
//  KEUtil.h
//  Kono
//
//  Created by Neo on 12/12/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KETextUtil.h"

/* define a string decrpt, strign can be decrypted via the following methods  */
@interface NSString (KECrypt)

- (NSString *)AES256DecryptWithKey:(NSString *)key andIV:(NSString*)iv;

@end

@interface NSString (KEString)

- (CGSize)sizeWithSystemFontSize:(UIFont *)font;

@end


@interface NSMutableDictionary (DefaultDictionary)

- (void)addObject:(id)obj forKey:(id<NSCopying>)key;

@end


@interface NSFileManager (manager)

- (void)moveAllFilesFromDir:(NSString*)sourceDir toDir:(NSString*)targetDir;

@end

@interface NSData (MD5)

- (NSString*)MD5String;

@end


@interface UIImageView (CryptUI)


- (void)setEncryptedImageWithFilePath:(NSString*)sourcePath withTargetPath:(NSString*)targetPath;

@end

@interface PushAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface PopAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface KEUtil : NSObject

/* get current ViewController */
+ (UIViewController *)getCurrentViewController;

+ (void)popToNavigationController:(UINavigationController *)rootNavigationController completion:(void (^)(void))completionBlock;


/* alert or toast */

+ (void)showGlobalAlert:(NSString*)msg;

/* device related */

+ (NSString*)getDeviceName;


/* file related */

+ (NSString *)getPDFPageRatio:(NSString *)htmlFileString;

+ (NSString *)getLandscapeHTML:(NSString *)magazineBid leftFilePath:(NSString *)leftFilePath withLeftRatio:(NSString *)leftFileRatio disableLeftPage:(BOOL)isLeftPageDisable rightFilePath:(NSString *)rightFilePath withRightRatio:(NSString *)rightFileRatio disableRightPage:(BOOL)isRightPageDisable ISOFilePath:(NSString *)ISOFilePath withISORatio:(NSString *)ISOFileRatio disableISOPage:(BOOL)isISOPageDisable isISOMode:(BOOL)isISOModeDisable;

+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (NSDictionary *)listFileAttribute:(NSString *)path;

+ (void)removeAllDataAtPath:(NSString*)path;


/* color tool function */
+ (UIColor *)colorWithHexString:(NSString*)hex;

+ (UIImage *)imageWithColor:(UIColor *)color; 


@end


