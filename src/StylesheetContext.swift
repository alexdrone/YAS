import Foundation

public struct StylesheetContext {
  /// Shorthand for the shared manager.
  static let manager = StylesheetManager.default
  /// Shorthand for the Dynamic lookup proxy.
  static let lookup = StyleDynamicLookup()
  /// Shorthand for the default object expressions registry.
  static let objectExpr = ObjectExprRegistry.default
}

extension Notification.Name {
  /// Posted whenever the stylesheet has been reloaded.
  static let StylesheetContextDidChange = Notification.Name("io.yas.StylesheetContextDidChange")
}
