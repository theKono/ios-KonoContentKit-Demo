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

/* alert or toast */
+ (void)showGlobalMessage:(NSString*)msg;

+ (void)showGlobalAlert:(NSString*)msg;

/* device related */
+ (BOOL)isTestMode;

+ (NSString*)getAPPVersion;

+ (uint64_t)getDeviceFreeDiskspace;

+ (NSString*)getDeviceID;

+ (NSString*)getDeviceName;

+ (NSString*)getAnnonymousID;

+ (NSString*)getRandomID;


/* file related */

+ (NSString*)jsonStringFromNSDictionary:(NSDictionary*)dic;

+ (void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath;

+ (void)clearBookTmpFiles;

+ (NSString*)getArticleImagePath;

+ (NSString *)getKonogramTemplatePath;

+ (NSString*)getOfflineRecordDir;

+ (NSString *)getPDFPageRatio:(NSString *)htmlFileString;

+ (NSString *)getLandscapeHTML:(NSString *)magazineBid leftFilePath:(NSString *)leftFilePath withLeftRatio:(NSString *)leftFileRatio disableLeftPage:(BOOL)isLeftPageDisable rightFilePath:(NSString *)rightFilePath withRightRatio:(NSString *)rightFileRatio disableRightPage:(BOOL)isRightPageDisable ISOFilePath:(NSString *)ISOFilePath withISORatio:(NSString *)ISOFileRatio disableISOPage:(BOOL)isISOPageDisable isISOMode:(BOOL)isISOModeDisable;

+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (NSArray *)listFileExistsAtPath:(NSString *)path;

+ (NSDictionary *)listFileAttribute:(NSString *)path;

+ (void)deleteCacheImageWithURL:(NSURL *)url;

+ (void)removeAllDataAtPath:(NSString*)path;

+ (void)removeExpireDataAtPath:(NSString*)path expireInterval:(NSNumber *)expireTime;

/* badge operation function */

+ (void)updateBadgeLabelWithText:(NSString*)labeltext atIndex:(int)idx;


/* text field operation function */

+ (BOOL)validateEmail:(NSString*)text;


/* upload local information */

+ (void)uploadUserLog;

+ (void)sendSupportMail;

+ (void)sendReferalMail:(NSString *)referalLink;


/* base 64 related */

+ (NSString*)MD5String:(NSString*)text;

+ (NSString*)magicCombine:(NSString*)text;

+ (NSString*)base64Encode:(NSData*)inputData;


/* crypt */

+ (NSString*)magicPassCode;

+ (NSData *)AES256DecryptWithData:(NSData*)data Key:(NSString *)key andIV:(NSString*)iv;

+ (void)decryptFilesFromDirectory:(NSString*)sourceDirectory toTargetDirectory:(NSString*)targetDirectory;

+ (void)decryptFileFromFile:(NSString*)sourcePath toFile:(NSString*)targetPath;

+ (void)decryptFileFromFile:(NSString *)sourcePath toFile:(NSString *)targetPath withCompleteBlock:(void(^)(void))completeBlock withFailBlock:(void(^)(void))failBlock;

+ (void)encryptFileFromPath:(NSString*)path toPath:(NSString*)targetPath withComplete:(void(^)(void))completeBlock withFail:(void(^)(NSError *error))failBlock;

// for download file, we have already open background thread for download
// we won't open another thread for decrypt, it will trigger error in background mode
+ (void)decryptKonoFileBlockFromSourcePath:(NSString *)sourcePath toPath:(NSString *)targetPath withPasscode:(NSString *)passcode withSecret:(NSString *)secret withComplete:(void (^)(void))completeBlock withFail:(void (^)(void))failBlock;

// for on-line pdf file decrypt
+ (void)decryptKonoFileFromSourcePath:(NSString*)sourcePath toPath:(NSString*)targetPath withPasscode:(NSString*)passcode withSecret:(NSString*)secret withComplete:(void(^)(void))completeBlock withFail:(void(^)(void))failBlock;

+ (void)encryptFilesFromDirectory:(NSString*)sourceDirectory withComplete:(void (^)(void))completeBlock withFail:(void (^)(NSError *error))failBlock;

/* color tool function */
+ (UIColor *)colorWithHexString:(NSString*)hex;

+ (UIImage *)imageWithColor:(UIColor *)color; 


@end


