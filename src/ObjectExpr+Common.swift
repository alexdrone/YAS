import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
struct ObjectExprCommon {

  class Font: ObjectExprBase {
    static let fontWeights = [
      "ultralight": CGFloat(-0.800000011920929),
      "thin": CGFloat(-0.600000023841858),
      "light": CGFloat(-0.400000005960464),
      "medium": CGFloat(0.230000004172325),
      "regular": CGFloat(0),
      "semibold": CGFloat(0.300000011920929),
      "bold": CGFloat(0.400000005960464),
      "heavy": CGFloat(0.560000002384186),
      "black": CGFloat(0.620000004768372)]

    @objc dynamic var name: String? = nil
    @objc dynamic var size: CGFloat = 10
    @objc dynamic var weight: String = "regular"

    override func eval() -> Any? {
      if let fontName = name {
        return UIFont(name: fontName, size: size)
      } else {
        let weights = ObjectExprCommon.Font.fontWeights
        let fontWeight = UIFont.Weight(rawValue: weights[weight] ?? 0)
        return UIFont.systemFont(ofSize: size, weight: fontWeight)
      }
    }
  }

  class Color: ObjectExprBase{
    @objc dynamic var hex: String = "000"
    @objc dynamic var darken: CGFloat = 0
    @objc dynamic var lighten: CGFloat = 0
    @objc dynamic var alpha: CGFloat = 1

    override func eval() -> Any? {
      var color = UIColor(hex: hex)
      if darken > 0 {
        color = color?.darker(by: darken)
      } else if lighten > 0 {
        color = color?.lighter(by: lighten)
      }
      if alpha < 1 {
        color = color?.withAlphaComponent(alpha)
      }
      return color
    }
  }

  class Animator: ObjectExprBase {
    @objc dynamic var duration: TimeInterval = 0
    @objc dynamic var curve: String = "linear"
    @objc dynamic var damping: CGFloat = CGFloat.nan

    override func eval() -> Any? {
      var animationCurve: UIView.AnimationCurve = .linear
      switch curve {
      case "easeInOut": animationCurve = .easeInOut
      case "easeIn" : animationCurve = .easeIn
      case "easeOut": animationCurve = .easeOut
      case "linear": animationCurve = .linear
      default: break
      }
      if damping.isNormal {
        return UIViewPropertyAnimator(
          duration: duration,
          dampingRatio: damping,
          animations: nil)
      } else {
        return UIViewPropertyAnimator(
          duration: duration,
          curve: animationCurve,
          animations:nil)
      }
    }
  }

  class AttributedString: ObjectExprBase {
    @objc dynamic var name: String? = nil
    @objc dynamic var size: CGFloat = 10
    @objc dynamic var kern: CGFloat = 1
    @objc dynamic var weight: String = "regular"
    @objc dynamic var supportDynamicType: Bool = true
    @objc dynamic var color: String = "000"

    override func eval() -> Any? {
      let uiColor = UIColor(hex: color) ?? UIColor.black
      var font = UIFont.systemFont(ofSize: size)
      if let fontName = name {
        font = UIFont(name: fontName, size: size)!
      } else {
        let weights = ObjectExprCommon.Font.fontWeights
        let fontWeight = UIFont.Weight(rawValue: weights[weight] ?? 0)
        font = UIFont.systemFont(ofSize: size, weight: fontWeight)
      }
      return NSAttributedStringBuilder(
        font: font,
        kern: kern,
        supportDynamicType: supportDynamicType,
        color: uiColor)
    }
  }
}
#endif

func objectExprRegisterDefaults(_ registry: ObjectExprRegistry) {
  #if canImport(UIKit)
  registry.export(ObjectExprFactory(
    type: ObjectExprCommon.Font.self,
    name: "font",
    ruleType: .font))
  registry.export(ObjectExprFactory(
    type: ObjectExprCommon.Color.self,
    name: "color",
    ruleType: .color))
  registry.export(ObjectExprFactory(
    type: ObjectExprCommon.Animator.self,
    name: "animator",
    ruleType: .animator))
  registry.export(ObjectExprFactory(
    type: ObjectExprCommon.AttributedString.self,
    name: "attributedString",
    ruleType: .attributedString))
  #endif
}
