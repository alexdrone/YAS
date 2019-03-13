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
    .variable("screenSize.height"): { _ in
      Double(Screen.default.state().screenSize.height) },
    .variable("screenSize.width"): { _ in
      Double(Screen.default.state().screenSize.width) }
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


#if canImport(UIKit)
extension NSTextAlignment: EnumRepresentable {
  public static func expressionConstants() -> [String : Double] {
    let namespace = "NSTextAlignment"
    return [
      "\(namespace).left": Double(NSTextAlignment.left.rawValue),
      "\(namespace).center": Double(NSTextAlignment.center.rawValue),
      "\(namespace).right": Double(NSTextAlignment.right.rawValue),
      "\(namespace).justified": Double(NSTextAlignment.justified.rawValue),
      "\(namespace).natural": Double(NSTextAlignment.natural.rawValue)]
  }
}

extension NSLineBreakMode: EnumRepresentable {
  public static func expressionConstants() -> [String : Double] {
    let namespace = "NSLineBreakMode"
    return [
      "\(namespace).byWordWrapping": Double(NSLineBreakMode.byWordWrapping.rawValue),
      "\(namespace).byCharWrapping": Double(NSLineBreakMode.byCharWrapping.rawValue),
      "\(namespace).byClipping": Double(NSLineBreakMode.byClipping.rawValue),
      "\(namespace).byTruncatingHead": Double(NSLineBreakMode.byTruncatingHead.rawValue),
      "\(namespace).byTruncatingMiddle": Double(NSLineBreakMode.byTruncatingMiddle.rawValue)]
  }
}

extension UIImage.Orientation: EnumRepresentable {
  public static func expressionConstants() -> [String : Double] {
    let namespace = "UIImageOrientation"
    return [
      "\(namespace).up": Double(UIImage.Orientation.up.rawValue),
      "\(namespace).down": Double(UIImage.Orientation.down.rawValue),
      "\(namespace).left": Double(UIImage.Orientation.left.rawValue),
      "\(namespace).right": Double(UIImage.Orientation.right.rawValue),
      "\(namespace).upMirrored": Double(UIImage.Orientation.upMirrored.rawValue),
      "\(namespace).downMirrored": Double(UIImage.Orientation.downMirrored.rawValue),
      "\(namespace).leftMirrored": Double(UIImage.Orientation.leftMirrored.rawValue),
      "\(namespace).rightMirrored": Double(UIImage.Orientation.rightMirrored.rawValue)]
  }
}

extension UIImage.ResizingMode: EnumRepresentable {
  public static func expressionConstants() -> [String : Double] {
    let namespace = "UIImageResizingMode"
    return [
      "\(namespace).title": Double(UIImage.ResizingMode.tile.rawValue),
      "\(namespace).stretch": Double(UIImage.ResizingMode.stretch.rawValue)]
  }
}

extension UIView.ContentMode: EnumRepresentable {
  public static func expressionConstants() -> [String : Double] {
    let namespace = "UIViewContentMode"
    return [
      "\(namespace).scaleToFill": Double(UIView.ContentMode.scaleToFill.rawValue),
      "\(namespace).scaleAspectFit": Double(UIView.ContentMode.scaleAspectFit.rawValue),
      "\(namespace).scaleAspectFill": Double(UIView.ContentMode.scaleAspectFill.rawValue),
      "\(namespace).redraw": Double(UIView.ContentMode.redraw.rawValue),
      "\(namespace).center": Double(UIView.ContentMode.center.rawValue),
      "\(namespace).top": Double(UIView.ContentMode.top.rawValue),
      "\(namespace).bottom": Double(UIView.ContentMode.bottom.rawValue),
      "\(namespace).left": Double(UIView.ContentMode.left.rawValue),
      "\(namespace).right": Double(UIView.ContentMode.right.rawValue),
      "\(namespace).topLeft": Double(UIView.ContentMode.topLeft.rawValue),
      "\(namespace).topRight": Double(UIView.ContentMode.topRight.rawValue),
      "\(namespace).bottomLeft": Double(UIView.ContentMode.bottomLeft.rawValue),
      "\(namespace).bottomRight": Double(UIView.ContentMode.bottomRight.rawValue)]
  }
}

// MARK: - Screen

public class Screen {
  /// Default singletion screen state factory.
  static let `default` = Screen()

  public enum Device: Int, Codable {
    /// Applicable for iPhone5, 5S, 5C and SE.
    case iPhoneSE
    /// Applicable for iPhone 6, 6S, 7 and 8.
    case iPhone8
    /// Applicable for iPhone 6+, 6S+, 7+ and 8+.
    case iPhone8Plus
    /// Applicable for iPhone X and XR,
    case iPhoneX
    /// Applicable for iPhone X Max.
    case iPhoneXMax
    /// Applicable for any iPad.
    case iPad
    /// Applicable for Apple TV.
    case tv
    /// Any other unsupported interface idiom.
    case undefined

    /// The interface idiom for the current device screen.
    static func current() -> Device {
      let idiom = UIDevice().userInterfaceIdiom
      switch idiom {
      case .phone:
        switch UIScreen.main.nativeBounds.height {
        case 568: return .iPhoneSE
        case 667: return .iPhone8
        case 736: return .iPhone8Plus
        case 812: return .iPhoneX
        case 896: return .iPhoneXMax
        default: return .undefined
        }
      case .pad: return .iPad
      case .tv: return .tv
      default: return .undefined
      }
    }
  }

  public enum Orientation: Int, Codable {
    case portrait
    case landscape

    /// Queries the physical orientation of the device.
    static func current() -> Orientation {
      return isPortrait() ? .portrait : landscape
    }
    /// Returns `true` if the phone is portrait, `false` otherwise.
    private static func isPortrait() -> Bool {
      let orientation = UIDevice.current.orientation
      switch orientation {
      case .portrait, .portraitUpsideDown: return true
      case .faceUp:
        // Check the interface orientation
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch interfaceOrientation{
        case .portrait, .portraitUpsideDown: return true
        default: return false
        }
      default: return false
      }
    }
    /// Returns `true` if the phone is landscape, `false` otherwise.
    private static func isLandscape() -> Bool {
      return !isPortrait()
    }
  }

  public enum SizeClass: Int, Codable {
    case unspecified
    /// Indicates a regular size class.
    case regular
    /// Indicates a compact size class.
    case compact

    public static func horizontalSizeClass(for view: UIView? = nil) -> SizeClass {
      switch (view?.traitCollection ?? UIScreen.main.traitCollection).horizontalSizeClass {
      case .regular: return .regular
      case .compact: return .compact
      case .unspecified: return .unspecified
      }
    }

    public static func verticalSizeClass(for view: UIView? = nil) -> SizeClass {
      switch (view?.traitCollection ?? UIScreen.main.traitCollection).verticalSizeClass {
      case .regular: return .regular
      case .compact: return .compact
      case .unspecified: return .unspecified
      }
    }
  }

  public struct State: Codable {
    /// The user interface idiom based on the screen size.
    public let idiom: Device
    /// The physical orientation of the device.
    public let orientation: Orientation
    /// The horizontal size class of the trait collection.
    public let horizontalSizeClass: SizeClass
    /// The vertical size class of the trait collection.
    public let verticalSizeClass: SizeClass
    /// The width and the height of the physical screen.
    public let screenSize: CGSize
    /// The width and the height of the canvas view for this context.
    public let canvasSize: CGSize
    /// The width and the height for the size passed as argument for this last render pass.
    public let renderSize: CGSize
    /// The safe area of a view reflects the area not covered by navigation bars, tab bars,
    /// toolbars, and other ancestors that obscure a view controller`s view.
    public let safeAreaSize: CGSize
    public let safeAreaInsets: Insets

    /// Edge inset values are applied to a rectangle to shrink or expand the area represented by
    /// that rectangle.
    public struct Insets: Codable {
      /// The inset on the top of an object.
      public let top: CGFloat
      /// The inset on the left of an object.
      public let left: CGFloat
      /// The inset on the bottom of an object.
      public let bottom: CGFloat
      /// The inset on the right of an object.
      public let right: CGFloat

      public var uiEdgeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
      }

      public static func from(edgeInsets: UIEdgeInsets) -> Insets {
        return Insets(
          top: edgeInsets.top,
          left: edgeInsets.left,
          bottom: edgeInsets.bottom,
          right: edgeInsets.right)
      }
    }
  }

  /// The canvas view in which the component will be rendered in.
  private var viewProvider: () -> UIView?
  /// The width and the height for the size passed as argument for this last render pass.
  public var bounds: CGSize = UIScreen.main.nativeBounds.size

  init(viewProvider: @escaping () -> UIView? = { nil }) {
    self.viewProvider = viewProvider
  }

  /// Returns the information about the screen at this very moment.
  public func state() -> State {
    let native = UIScreen.main.nativeBounds.size
    // Compute the Safe Area (if applicable).
    var safeAreaSize = native
    var safeAreaInsets = State.Insets(top: 0, left: 0, bottom: 0, right: 0)
    if #available(iOS 11.0, *) {
      let defaultView = UIApplication.shared.keyWindow?.rootViewController?.view
      if let view = viewProvider() ?? defaultView {
        safeAreaInsets = State.Insets.from(edgeInsets: view.safeAreaInsets)
        safeAreaSize.width -= safeAreaInsets.left + safeAreaInsets.right
        safeAreaSize.height -= safeAreaInsets.top + safeAreaInsets.bottom
      }
    }
    return State(
      idiom: Device.current(),
      orientation: Orientation.current(),
      horizontalSizeClass: SizeClass.horizontalSizeClass(for: viewProvider()),
      verticalSizeClass: SizeClass.verticalSizeClass(for: viewProvider()),
      screenSize: native,
      canvasSize: viewProvider()?.bounds.size ?? native,
      renderSize: bounds,
      safeAreaSize: safeAreaSize,
      safeAreaInsets: safeAreaInsets)
  }
}
#endif
