import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct ConstExpr {

  #if canImport(UIKit)
  private static let defaultConstants: [String: Double] = [
    // Idiom.
    "iPhoneSE": Double(Screen.Device.iPhoneSE.rawValue),
    "iPhone8": Double(Screen.Device.iPhone8.rawValue),
    "iPhone8Plus": Double(Screen.Device.iPhone8Plus.rawValue),
    "iPhoneX": Double(Screen.Device.iPhoneX.rawValue),
    "iPhoneXMax": Double(Screen.Device.iPhoneXMax.rawValue),
    "iPad": Double(Screen.Device.iPad.rawValue),
    "tv": Double(Screen.Device.tv.rawValue),
    // Bounds.
    "iPhoneSE.height": Double(568),
    "iPhone8.height": Double(667),
    "iPhone8Plus.height": Double(736),
    "iPhoneX.height": Double(812),
    "iPhoneXSMax.height": Double(896),
    "iPhoneSE.width": Double(320),
    "iPhone8.width": Double(375),
    "iPhone8Plus.width": Double(414),
    "iPhoneX.width": Double(375),
    "iPhoneXSMax.width": Double(414),
    // Orientation and Size Classes.
    "portrait": Double(Screen.Orientation.portrait.rawValue),
    "landscape": Double(Screen.Orientation.landscape.rawValue),
    "compact": Double(Screen.SizeClass.compact.rawValue),
    "regular": Double(Screen.SizeClass.regular.rawValue),
    "unspecified": Double(Screen.SizeClass.unspecified.rawValue),
    // Yoga.
    "inherit": Double(0),
    "ltr": Double(1),
    "rtl": Double(2),
    "auto": Double(0),
    "flexStart": Double(1),
    "center": Double(2),
    "flexEnd": Double(3),
    "stretch": Double(4),
    "baseline": Double(5),
    "spaceBetween": Double(6),
    "spaceAround": Double(7),
    "flex": Double(0),
    "none": Double(1),
    "column": Double(0),
    "columnReverse": Double(1),
    "row": Double(2),
    "rowReverse": Double(3),
    "visible": Double(0),
    "hidden": Double(1),
    "absolute": Double(2),
    "noWrap": Double(0),
    "wrap": Double(1),
    "wrapReverse": Double(2),
    ]
  private static let defaultSymbols: [Expression.Symbol: Expression.SymbolEvaluator] = [
    .variable("idiom"): { _ in
      Double(Screen.Device.current().rawValue) },
    .variable("orientation"): { _ in
      Double(Screen.Orientation.current().rawValue) },
    .variable("verticalSizeClass"): { _ in
      Double(Screen.SizeClass.verticalSizeClass().rawValue) },
    .variable("horizontalSizeClass"): { _ in
      Double(Screen.SizeClass.horizontalSizeClass().rawValue) },
    .variable("parentSize.height"): { _ in
      Double(StylesheetManager.default.parentSize.height) },
    .variable("parentSize.width"): { _ in
      Double(StylesheetManager.default.parentSize.width) },
    ]
  private static var exportedConstants: [String: Double] = defaultConstants
  private static var exportedConstantsInitialised: Bool = false
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
    return Expression(string,
                      options: [Expression.Options.boolSymbols, Expression.Options.pureSymbols],
                      constants: ConstExpr.exportedConstants,
                      symbols: ConstExpr.defaultSymbols)
    #else
    return Expression(string,
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
