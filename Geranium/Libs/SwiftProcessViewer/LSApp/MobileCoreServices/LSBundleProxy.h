#import "LSResourceProxy.h"

API_AVAILABLE(ios(8.0))
@interface LSBundleProxy : LSResourceProxy

+ (instancetype)bundleProxyForCurrentProcess API_AVAILABLE(ios(10.0));
+ (instancetype)bundleProxyForIdentifier:(NSString *)identifier;
+ (instancetype)bundleProxyForURL:(NSURL *)url;

@property (nonatomic, readonly) NSUUID *cacheGUID;

@property (nonatomic, copy) NSURL *appStoreReceiptURL;
@property (nonatomic, readonly) NSURL *bundleContainerURL;
@property (nonatomic, readonly) NSURL *bundleURL;
@property (nonatomic, readonly) NSURL *containerURL;
@property (nonatomic, readonly) NSURL *dataContainerURL;

@property (nonatomic, readonly) NSString *bundleExecutable;
@property (nonatomic, readonly) NSString *bundleIdentifier;
@property (nonatomic, readonly) NSString *bundleType;
@property (nonatomic, readonly) NSString *canonicalExecutablePath API_AVAILABLE(ios(10.3));

@property (nonatomic, readonly) NSDictionary <NSString *, NSString *> *entitlements;
@property (nonatomic, readonly) NSDictionary <NSString *, NSString *> *environmentVariables;
@property (nonatomic, readonly) NSDictionary <NSString *, NSURL *> *groupContainerURLs;

@property (nonatomic, copy) NSArray <NSUUID *> *machOUUIDs;
@property (nonatomic, readonly) NSString *signerIdentity;
@property (nonatomic, readonly, getter=isContainerized) BOOL containerized API_AVAILABLE(ios(11.0));
@property (nonatomic, readonly) BOOL profileValidated API_AVAILABLE(ios(11.0));

@property (nonatomic, readonly) NSString *localizedShortName;

- (NSUUID *)uniqueIdentifier API_AVAILABLE(ios(9.0));

@end
