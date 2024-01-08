#import "LSBundleProxy.h"

API_AVAILABLE(ios(8.0))
@interface LSPlugInKitProxy : LSBundleProxy

+ (instancetype)pluginKitProxyForIdentifier:(NSString *)identifier;
+ (instancetype)pluginKitProxyForURL:(NSURL *)url;

@property (nonatomic, readonly) LSBundleProxy *containingBundle;
@property (nonatomic, readonly) NSDictionary *infoPlist;
@property (nonatomic, readonly) NSString *pluginIdentifier;
@property (nonatomic, readonly) NSString *originalIdentifier API_AVAILABLE(ios(9.0));

@property (nonatomic, readonly) NSUUID *pluginUUID;
@property (nonatomic, readonly) NSString *protocol;
@property (nonatomic, readonly) NSDate *registrationDate;
@property (nonatomic, readonly) NSString *teamID API_AVAILABLE(ios(10.0));

@end
