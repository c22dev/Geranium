#import <Foundation/Foundation.h>

@interface NSString (LSAdditions)

- (instancetype)iTunesStoreURL;

@property (nonatomic, retain, readonly) NSDictionary *queryToDict;

@end
