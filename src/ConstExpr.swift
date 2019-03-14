import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol EnumRepresentable {
  /// Every `EnumRepresentable` must be backed by an integer store.
  init?(rawValue: Int)
  /// Returns every enum value as a map between a 'key' and its integer representation.
  static func expressionConstants() -> [String: Double]
}

public extension EnumRepresentable {
  /// Export this enum into the stylesheet global symbols.
  static func export() {
    ConstExpr.export(constants: expressionConstants())
  }
}

public struct ConstExpr {
  #if canImport(UIKit)
  private static let defaultConstants = defaultUIKitConstExpr
  private static let defaultSymbols = defaultUIKitSymbols
  private static var exportedConstants = defaultConstants
  private static var exportedConstantsInitialised = false
  #else
  private static var exportedConstants: [String: Double] = [:]
  #endif

  /// Export this enum into the stylesheet global symbols.
  static public func export(constants: [String: Double]) {
    assert(Thread.isMainThread)
    for (key, value) in constants {
      exportedConstants[key] = value
    }
  }

  /// The default `Expression` builder function.
  static func builder(_ string: String) -> Expression {
    #if canImport(UIKit)
    if !ConstExpr.exportedConstantsInitialised {
      ConstExpr.exportedConstantsInitialised = true
      NSTextAlignment.export()
      NSLineBreakMode.export()
      UIImage.Orientation.export()
      UIImage.ResizingMode.export()
      UIView.ContentMode.export()
    }
    return Expression(
      string,
      options: [Expression.Options.boolSymbols, Expression.Options.pureSymbols],
      constants: ConstExpr.exportedConstants,
      symbols: ConstExpr.defaultSymbols)
    #else
    return Expression(
      string,
      options: [Expression.Options.boolSymbols, Expression.Options.pureSymbols],
      constants: ConstExpr.exportedConstants,
      symbols: [:])
    #endif
  }

  /// Parse an expression.
  /// - note: The expression delimiter is ${EXPR}.
  static func sanitize(expression: String) -> String? {
    struct Token {
      /// Expression escape char.
      static let escape = "$"
      /// Expression brackets.
      static let block = ("{", "}")
    }
    guard expression.hasPrefix(Token.escape) else { return nil }
    let substring = expression
      .replacingOccurrences(of: Token.escape, with: "")
      .replacingOccurrences(of: Token.block.0, with: "")
      .replacingOccurrences(of: Token.block.1, with: "")
    return substring
  }
}
