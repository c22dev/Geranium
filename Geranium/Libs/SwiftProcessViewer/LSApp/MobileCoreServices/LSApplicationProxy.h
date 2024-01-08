#import "LSBundleProxy.h"

@class LSPlugInKitProxy;

API_AVAILABLE(ios(4.0))
@interface LSApplicationProxy : LSBundleProxy

+ (instancetype)applicationProxyForIdentifier:(NSString *)identifier;

@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *vendorName   API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly) NSString *itemName     API_AVAILABLE(ios(7.1));
@property (nonatomic, readonly) NSString *sdkVersion   API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSString *teamID       API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSDate *registeredDate API_AVAILABLE(ios(9.0));
@property (nonatomic, readonly) NSString *sourceAppIdentifier API_AVAILABLE(ios(8.2)); // e.g. App Store, TestFlight

@property (nonatomic, readonly) NSArray <LSPlugInKitProxy *> *plugInKitPlugins API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSArray <NSNumber *> *deviceFamily  API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSArray <NSString *> *activityTypes API_AVAILABLE(ios(10.0));

@property (nonatomic, readonly, getter=isAppUpdate) BOOL appUpdate API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly, getter=isInstalled) BOOL installed API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly, getter=isNewsstandApp) BOOL newsstandApp API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly, getter=isPlaceholder) BOOL placeholder   API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly, getter=isRestricted) BOOL restricted     API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly, getter=isPurchasedReDownload) BOOL purchasedReDownload API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly, getter=isWatchKitApp) BOOL watchKitApp API_AVAILABLE(ios(8.2));
@property (nonatomic, readonly, getter=isBetaApp) BOOL betaApp         API_AVAILABLE(ios(8.2));
@property (nonatomic, readonly, getter=isAdHocCodeSigned) BOOL adHocCodeSigned   API_AVAILABLE(ios(9.0));
@property (nonatomic, readonly, getter=isLaunchProhibited) BOOL launchProhibited API_AVAILABLE(ios(10.0));
@property (nonatomic, readonly, getter=isAppStoreVendable) BOOL appStoreVendable API_AVAILABLE(ios(11.0));

@property (nonatomic, readonly) BOOL isStickerProvider API_DEPRECATED("Removed in iOS 11", ios(10.0, 11.0));

@end
