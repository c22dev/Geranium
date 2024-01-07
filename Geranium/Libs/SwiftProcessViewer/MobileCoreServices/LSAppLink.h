#import <Foundation/Foundation.h>

@class LSApplicationProxy;

typedef NS_ENUM(NSInteger, LSAppLinkOpenStrategy) {
	LSAppLinkOpenStrategyUnknown = -1,
	LSAppLinkOpenStrategyApp,
	LSAppLinkOpenStrategyIdk,
	LSAppLinkOpenStrategyBrowser,
};

API_AVAILABLE(ios(9.0))
@interface LSAppLink : NSObject

+ (instancetype)_appLinkWithURL:(NSURL *)url applicationProxy:(LSApplicationProxy *)applicationProxy plugIn:(id)plugIn error:(NSError **)error API_DEPRECATED_WITH_REPLACEMENT("_appLinkWithURL:applicationProxy:plugIn:", ios(9.0, 11.0));
+ (instancetype)_appLinkWithURL:(NSURL *)url applicationProxy:(LSApplicationProxy *)applicationProxy plugIn:(id)plugIn API_AVAILABLE(ios(11.0));

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) LSApplicationProxy *targetApplicationProxy;
@property LSAppLinkOpenStrategy openStrategy;

@end
