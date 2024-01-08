#import <Foundation/Foundation.h>

@class LSApplicationProxy, LSBundleProxy, LSDocumentProxy, LSPlugInKitProxy;

API_AVAILABLE(ios(5.0))
@interface LSApplicationWorkspace : NSObject

+ (instancetype)defaultWorkspace;

- (NSArray <LSApplicationProxy *> *)allApplications          API_AVAILABLE(ios(7.0));
- (NSArray <LSApplicationProxy *> *)allInstalledApplications API_AVAILABLE(ios(7.0));
- (NSArray <LSApplicationProxy *> *)directionsApplications   API_AVAILABLE(ios(6.0));
- (NSArray <LSApplicationProxy *> *)unrestrictedApplications API_AVAILABLE(ios(7.0));

- (NSArray <NSString *> *)installedApplications        API_AVAILABLE(ios(6.0));
- (NSArray <NSString *> *)removedSystemApplications    API_AVAILABLE(ios(9.3));
- (BOOL)restoreSystemApplication:(NSString *)bundleID  API_AVAILABLE(ios(9.3));

- (NSArray <LSApplicationProxy *> *)applicationsAvailableForHandlingURLScheme:(NSString *)urlScheme;
- (NSArray <LSApplicationProxy *> *)applicationsAvailableForOpeningDocument:(LSDocumentProxy *)document;
- (NSArray <LSApplicationProxy *> *)applicationsAvailableForOpeningURL:(NSURL *)url API_AVAILABLE(ios(10.0));
- (NSArray <LSApplicationProxy *> *)applicationsAvailableForOpeningURL:(NSURL *)url legacySPI:(BOOL)legacySPI API_AVAILABLE(ios(10.0));

- (LSApplicationProxy *)applicationForUserActivityDomainName:(NSString *)domain API_AVAILABLE(ios(8.0));
- (LSApplicationProxy *)applicationForUserActivityType:(NSString *)activityType API_AVAILABLE(ios(8.0));
- (NSArray <LSApplicationProxy *> *)applicationsForUserActivityType:(NSString *)activityType API_AVAILABLE(ios(10.0));
- (NSArray <LSApplicationProxy *> *)applicationsForUserActivityType:(NSString *)activityType limit:(NSUInteger)limit API_AVAILABLE(ios(10.0));;
- (BOOL)getClaimedActivityTypes:(NSSet<NSString *> **)activityTypes domains:(NSSet<NSString *> **)domains API_AVAILABLE(ios(8.0));

- (NSURL *)URLOverrideForURL:(NSURL *)url API_AVAILABLE(ios(6.0));

- (NSArray <NSString *> *)publicURLSchemes  API_AVAILABLE(ios(6.0));
- (NSArray <NSString *> *)privateURLSchemes API_AVAILABLE(ios(6.0));

// convience method for the respective openURL with `LSOpenSensitiveURLOption : YES` set in options
- (BOOL)openSensitiveURL:(NSURL *)url withOptions:(NSDictionary <NSString *, id> *)options API_AVAILABLE(ios(6.0));
- (BOOL)openSensitiveURL:(NSURL *)url withOptions:(NSDictionary <NSString *, id> *)options error:(NSError **)error API_AVAILABLE(ios(9.0));

- (BOOL)openURL:(NSURL *)url API_AVAILABLE(ios(6.0));
- (BOOL)openURL:(NSURL *)url withOptions:(NSDictionary <NSString *, id> *)options API_AVAILABLE(ios(6.0));
- (BOOL)openURL:(NSURL *)url withOptions:(NSDictionary <NSString *, id> *)options error:(NSError **)error API_AVAILABLE(ios(6.0));

- (void)openApplicationWithBundleID:(NSString *)bundleID API_AVAILABLE(ios(7.0));

- (BOOL)registerApplication:(NSURL *)url;
- (BOOL)unregisterApplication:(NSURL *)url;

- (BOOL)registerPlugin:(NSURL *)url   API_AVAILABLE(ios(8.0));
- (BOOL)unregisterPlugin:(NSURL *)url API_AVAILABLE(ios(8.0));

// version unused as of iOS 10.2
// returns the union of matches. pass empty arrays to get all plugins
- (NSArray <LSPlugInKitProxy *> *)pluginsWithIdentifiers:(NSArray <NSString *> *)identifiers protocols:(NSArray <NSString *> *)protocols version:(id)version API_AVAILABLE(ios(8.0));

- (void)enumerateBundlesOfType:(NSInteger)type block:(void (^)(LSBundleProxy *))block;

@end
