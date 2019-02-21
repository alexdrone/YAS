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
#endif
