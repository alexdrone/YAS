#import "YASObjcExceptionHandler.h"

@implementation YASObjcExceptionHandler

+ (void)tryBlock:(void (^)(void))tryBlock
    catchAndRethrowBlock:(BOOL (^)(id))catchAndRethrowBlock
            finallyBlock:(void (^)(void))finallyBlock {
  @try {
    tryBlock();
  } @catch (id exception) {
    if (catchAndRethrowBlock && catchAndRethrowBlock(exception)) {
      @throw;
    }
  } @finally {
    if (finallyBlock) {
      finallyBlock();
    }
  }
}

@end
