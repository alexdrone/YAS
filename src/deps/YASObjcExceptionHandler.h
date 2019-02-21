#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YASObjcExceptionHandler : NSObject

+ (void)tryBlock:(nonnull void (^)(void))tryBlock
    catchAndRethrowBlock:(nullable BOOL (^)(_Nonnull id))catchAndRethrowBlock
            finallyBlock:(nullable void (^)(void))finallyBlock;

@end

NS_ASSUME_NONNULL_END
