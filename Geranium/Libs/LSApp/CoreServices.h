@import Foundation;
extern NSString *LSInstallTypeKey;

@interface LSBundleProxy
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic) NSURL* dataContainerURL;
@property (nonatomic,readonly) NSURL* bundleContainerURL;
-(NSString*)localizedName;
@end

@interface LSApplicationProxy : NSObject
@property (readonly, nonatomic) NSString *applicationType;

@property (getter=isBetaApp, readonly, nonatomic) BOOL betaApp;
@property (getter=isDeletable, readonly, nonatomic) BOOL deletable;
@property (getter=isRestricted, readonly, nonatomic) BOOL restricted;
@property (getter=isContainerized, readonly, nonatomic) BOOL containerized;
@property (getter=isAdHocCodeSigned, readonly, nonatomic) BOOL adHocCodeSigned;
@property (getter=isAppStoreVendable, readonly, nonatomic) BOOL appStoreVendable;
@property (getter=isLaunchProhibited, readonly, nonatomic) BOOL launchProhibited;

@property (readonly, nonatomic) NSSet <NSString *> *claimedURLSchemes;
@property (readonly, nonatomic) NSString *teamID;
@property (copy, nonatomic) NSString *sdkVersion;
@property (readonly, nonatomic) NSDictionary <NSString *, id> *entitlements;
@property (readonly, nonatomic) NSURL* _Nullable bundleContainerURL;
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic) NSURL* dataContainerURL;

+ (LSApplicationProxy*)applicationProxyForIdentifier:(id)identifier;
- (NSString *)applicationIdentifier;
- (NSURL *)containerURL;
- (NSURL *)bundleURL;
- (NSString *)localizedName;
- (NSData *)iconDataForVariant:(id)variant;
- (NSData *)iconDataForVariant:(id)variant withOptions:(id)options;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (BOOL)registerApplicationDictionary:(NSDictionary*)dict;
- (BOOL)unregisterApplication:(id)arg1;
- (BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
- (BOOL)openApplicationWithBundleID:(NSString *)arg1 ;
- (void)enumerateApplicationsOfType:(NSUInteger)type block:(void (^)(LSApplicationProxy*))block;
- (BOOL)installApplication:(NSURL*)appPackageURL withOptions:(NSDictionary*)options error:(NSError**)error;
- (BOOL)uninstallApplication:(NSString*)appId withOptions:(NSDictionary*)options;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (NSArray <LSApplicationProxy *> *)allInstalledApplications;
- (NSArray <LSApplicationProxy *> *)allApplications;
@end

@protocol LSApplicationWorkspaceObserverProtocol <NSObject>
@optional
-(void)applicationsDidInstall:(id)arg1;
-(void)applicationsDidUninstall:(id)arg1;
@end

@interface LSEnumerator : NSEnumerator
@property (nonatomic,copy) NSPredicate * predicate;
+ (instancetype)enumeratorForApplicationProxiesWithOptions:(NSUInteger)options;
@end

@interface LSPlugInKitProxy : LSBundleProxy
@property (nonatomic,readonly) NSString* pluginIdentifier;
@property (nonatomic,readonly) NSDictionary * pluginKitDictionary;
+ (instancetype)pluginKitProxyForIdentifier:(NSString*)arg1;
@end

@interface MCMContainer : NSObject
+ (id)containerWithIdentifier:(id)arg1 createIfNecessary:(BOOL)arg2 existed:(BOOL*)arg3 error:(id*)arg4;
@property (nonatomic,readonly) NSURL * url;
@end

@interface MCMDataContainer : MCMContainer
@end

@interface MCMAppDataContainer : MCMDataContainer
@end

@interface MCMAppContainer : MCMContainer
@end

@interface MCMPluginKitPluginDataContainer : MCMDataContainer
@end

@interface MCMSystemDataContainer : MCMContainer
@end

@interface MCMSharedDataContainer : MCMContainer
@end
