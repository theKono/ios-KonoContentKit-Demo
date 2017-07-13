//
//  KETextUtil.m
//  Kono
//
//  Created by Neo on 5/8/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KETextUtil.h"

@implementation KETextUtil



+ (NSAttributedString *)magazineInfoDescription:(NSString*)infoString{

    if( infoString == nil ){
        return nil;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineHeightMultiple:1.2];
    [paragraphStyle setAlignment: NSTextAlignmentJustified];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle  };
    
    NSAttributedString *attMsg = [[NSAttributedString alloc] initWithString:infoString attributes:attributes];
    
    return attMsg;
}

+ (NSAttributedString *)attributedStringWithColor:(UIColor *)color withFontSize:(float)size withText:(NSString*)text{
    
    if( text == nil ){
        return nil;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineHeightMultiple:1.2];
    [paragraphStyle setAlignment: NSTextAlignmentJustified];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:size], NSParagraphStyleAttributeName: paragraphStyle,  NSForegroundColorAttributeName:color };
    
    NSAttributedString *attMsg = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    return attMsg;
    
}

+ (NSAttributedString *)attributedStringWithColor:(UIColor *)color withFontSize:(float)size withLineSpacing:(float)lineSpacing withText:(NSString*)text{
    
    if( text == nil || ![text isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setAlignment: NSTextAlignmentJustified];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:size], NSParagraphStyleAttributeName: paragraphStyle,  NSForegroundColorAttributeName:color };
    
    NSAttributedString *attMsg = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    return attMsg;
    
}

+ (NSAttributedString *)attributedStringWithColor:(UIColor *)color withFontSize:(float)size withLineSpacing:(float)lineSpacing withTruncateMode:(NSLineBreakMode)mode withText:(NSString*)text{
    
    if( text == nil || ![text isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:mode];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedText length])];
    
    
    return attributedText;
    
}


@end
