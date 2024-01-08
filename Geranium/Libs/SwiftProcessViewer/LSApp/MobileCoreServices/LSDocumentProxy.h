#import "LSResourceProxy.h"

API_AVAILABLE(ios(5.0))
@interface LSDocumentProxy : LSResourceProxy

@property (readonly, nonatomic) NSString *name           API_AVAILABLE(ios(6.0));
@property (readonly, nonatomic) NSString *typeIdentifier API_AVAILABLE(ios(6.0));
@property (readonly, nonatomic) NSString *MIMEType       API_AVAILABLE(ios(6.0));
@property (readonly, nonatomic) BOOL sourceIsManaged     API_AVAILABLE(ios(7.0));
@property (readonly, nonatomic) NSURL *URL               API_AVAILABLE(ios(9.0));
@property (readonly, nonatomic) NSString *containerOwnerApplicationIdentifier API_AVAILABLE(ios(9.0));

+ (instancetype)documentProxyForName:(NSString *)name type:(NSString *)type MIMEType:(NSString *)MIME;
+ (instancetype)documentProxyForName:(NSString *)name type:(NSString *)type MIMEType:(NSString *)MIME sourceIsManaged:(BOOL)isManaged API_AVAILABLE(ios(7.0));
+ (instancetype)documentProxyForURL:(NSURL *)url sourceIsManaged:(BOOL)isManaged API_AVAILABLE(ios(9.0));

@end
