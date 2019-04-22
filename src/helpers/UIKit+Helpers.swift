import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Warning message related to stylesheet parsing and rules evaluation.
func warn(_ message: String) {
  print("warning \(#function): \(message)")
}

#if canImport(UIKit)
public extension UIColor {
  /// Parse a color from a haxadecimal string.
  convenience init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    var rgb: UInt32 = 0
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0
    let length = hexSanitized.count
    guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0

    } else if length == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x000000FF) / 255.0
    } else {
      return nil
    }
    self.init(red: r, green: g, blue: b, alpha: a)
  }

  func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: abs(percentage) )
  }

  func darker(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: -1 * abs(percentage) )
  }

  func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(
        red: min(red + percentage/100, 1.0),
        green: min(green + percentage/100, 1.0),
        blue: min(blue + percentage/100, 1.0),
        alpha: alpha)
    } else {
      return nil
    }
  }
}

/// Fonts and its attributes.
public class TextStyle: NSObject {
  /// The typeface.
  private let internalFont: UIFont
  /// The font letter spacing.
  private let kern: CGFloat
  /// Whether this font support dybamic font size.
  private var supportDynamicType: Bool
  /// The font color.
  public var color: UIColor
  /// Publicly exposed font (subject to font scaling if appliocable).
  public var font: UIFont {
    guard supportDynamicType else {
      return internalFont
    }
    if #available(iOS 11.0, *) {
      return UIFontMetrics.default.scaledFont(for: internalFont)
    } else {
      return internalFont
    }
  }

  public init(
    font: UIFont = UIFont.systemFont(ofSize: 10),
    kern: CGFloat = 1,
    supportDynamicType: Bool = false,
    color: UIColor = .black
  ) {
    self.internalFont = font
    self.kern = kern
    self.supportDynamicType = supportDynamicType
    self.color = color
  }

  /// Returns a dictionary of attributes for `NSAttributedString`.
  public var attributes: [NSAttributedString.Key: Any] {
    return [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: color,
      NSAttributedString.Key.kern: kern
    ]
  }
  /// Overrides the `NSForegroundColorAttributeName` attribute.
  public func withColor(_ override: UIColor) -> TextStyle {
    return TextStyle(
      font: internalFont,
      kern: kern,
      supportDynamicType: supportDynamicType,
      color: override)
  }
  /// Returns an attributed string with the current font descriptor attributes.
  public func asAttributedString(_ string: String) -> NSAttributedString {
    return NSAttributedString(string: string, attributes: attributes)
  }
}

extension UIImageView {
  /// Configure this image view to work with the icon passed as argument.
  /// - parameter icon: The icon name, see *Icons.generated.swift*.
  /// - parameter size: The optional icon size (with the assumption that the icon is squared).
  /// - parameter color: Tint the image with the desired color.
  @discardableResult
  func withIcon(_ icon: String, size: CGFloat? = nil, color: UIColor? = nil) -> UIImageView {
    guard let icon = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) else { return self }
    image = icon
    if let size = size { frame.size = CGSize(width: size, height: size) }
    if let color = color { tintColor = color }
    return self
  }
}

public extension UIImage {
  /// Tint the image with the desired color.
  func withTintColor(_ color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.translateBy(x: 0, y: self.size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    context.setBlendMode(CGBlendMode.normal)
    let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    context.clip(to: rect, mask: self.cgImage!)
    color.setFill()
    context.fill(rect)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }

  /// Resize an image.
  func byResizingToTargetHeight(_ targetHeight: CGFloat) -> UIImage {
    let size = self.size
    let heightRatio = targetHeight / size.height
    let newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
}
#endif
