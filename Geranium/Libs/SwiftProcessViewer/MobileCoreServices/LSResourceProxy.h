#import "_LSQueryResult.h"

API_AVAILABLE(ios(4.0)) // subclass of NSObject until iOS 10.0
@interface LSResourceProxy : _LSQueryResult

@property (nonatomic, copy) NSString *boundApplicationIdentifier;
@property (nonatomic, copy) NSURL *boundContainerURL API_AVAILABLE(ios(5.0));
@property (nonatomic, copy) NSURL *boundDataContainerURL API_DEPRECATED("Access through the appropriate subclass property", ios(8.0, 11.0));

@property (nonatomic, retain) NSString *localizedName;

@end
