#if canImport(UIKit)
import UIKit

public extension UIView {
  /// Applies a style definition to this view.
  @nonobjc func apply(style: [String: Rule]?) {
    guard let style = style else {
      return
    }
    assert(Thread.isMainThread)
    for (key, rule) in style {
      YASObjcExceptionHandler.try({ [weak self] in
          self?.setValue(rule.object, forKeyPath: key)
      },
        catchAndRethrow: nil,
        finallyBlock: nil)
    }
  }
}
#endif
