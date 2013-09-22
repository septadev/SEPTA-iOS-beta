//
//  NSString+Hashes.m
//  LIFTUPP
//
//  Created by Klaus-Peter Dudas on 26/07/2011.
//  Copyright: Do whatever you want with this, i.e. Public Domain
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+Hashes.h"

@implementation NSString (Hashes)


//-(BOOL)isBlank {
//    if([[self stringByStrippingWhitespace] isEqualToString:@""])
//        return YES;
//    return NO;
//}
//
//-(BOOL)contains:(NSString *)string {
//    NSRange range = [self rangeOfString:string];
//    return (range.location != NSNotFound);
//}
//
//-(NSString *)stringByStrippingWhitespace {
//    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//}
//
//-(NSArray *)splitOnChar:(char)ch {
//    NSMutableArray *results = [[NSMutableArray alloc] init];
//    int start = 0;
//    for(int i=0; i<[self length]; i++) {
//        
//        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
//        BOOL isAtEnd = i == [self length] - 1;
//        
//        if(isAtSplitChar || isAtEnd) {
//            //take the substring &amp; add it to the array
//            NSRange range;
//            range.location = start;
//            range.length = i - start + 1;
//            
//            if(isAtSplitChar)
//                range.length -= 1;
//            
//            [results addObject:[self substringWithRange:range]];
//            start = i + 1;
//        }
//        
//        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
//        if(isAtEnd && isAtSplitChar)
//            [results addObject:@""];
//    }
//    
//    return results;
//}
//
//-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
//    NSString *rightPart = [self substringFromIndex:from];
//    return [rightPart substringToIndex:to-from];
//}


- (NSString *)md5
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_MD5_DIGEST_LENGTH];

    CC_MD5(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)sha256
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)sha512
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
