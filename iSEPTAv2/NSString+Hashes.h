//
//  NSString+Hashes.h
//  LIFTUPP
//
//  Created by Klaus-Peter Dudas on 26/07/2011.
//  Copyright: Do whatever you want with this, i.e. Public Domain
//

#import <Foundation/Foundation.h>

NSString *NSStringNotNull(NSString *string);

@interface NSString (Hashes)

//-(BOOL)isBlank;
//-(BOOL)contains:(NSString *)string;
//-(NSArray *)splitOnChar:(char)ch;
//-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
//-(NSString *)stringByStrippingWhitespace;

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)sha256;
- (NSString *)sha512;

@end
