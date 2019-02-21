import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class FuncExprRegistry {
  /// Singleton instance.
  static let `default` = FuncExprRegistry()
  /// The functions currently registred.
  var functions: [FuncExpr]

  private init() {
    #if canImport(UIKit)
    // - `color(string [color hexcode])`: Returns a color.
    let colorFunc = FuncExpr(name: "color", arity: 1) { args in
      return (.color, UIColor(hex: args[0]) ?? .black)
    }

    // - `font(string [font name or `system`], number [point size])`
    let fontFunc = FuncExpr(name: "font", arity: 2) { args in
      let systemFontName = "system"
      let size: CGFloat = CGFloat(parse(numberFromString: args[1]).floatValue)
      return (.font, args[0].lowercased() == systemFontName
        ? UIFont.systemFont(ofSize: size)
        : UIFont(name:  args[0], size: size))
    }
    // - `systemfont(number [point size], weight [ultralight, thin, ..., black])`
    let sysFontFunc = FuncExpr(name: "systemfont", arity: 2) { args in
      let size: CGFloat = CGFloat(parse(numberFromString: args[0]).floatValue)
      let weights = [
        "ultralight": CGFloat(-0.800000011920929),
        "thin": CGFloat(-0.600000023841858),
        "light": CGFloat(-0.400000005960464),
        "medium": CGFloat(0.230000004172325),
        "semibold": CGFloat(0.300000011920929),
        "bold": CGFloat(0.400000005960464),
        "heavy": CGFloat(0.560000002384186),
        "black": CGFloat(0.620000004768372)]
      let weight = UIFont.Weight(rawValue: weights[args[1]] ?? 0)
      return (.font, UIFont.systemFont(ofSize: size, weight: weight))
    }

    // `animator(number [duration], string [easeIn, easeOut, easeInOut, linear])` or
    // `animator(number [duration], number [damping])`
    let animatorFunc = FuncExpr(name: "animator", arity: 2) { args in
      let duration: TimeInterval = parse(numberFromString: args[0]).doubleValue
      var curve: UIView.AnimationCurve = .linear
      var damping: CGFloat = CGFloat.nan
      switch args[1] {
      case "easeInOut": curve = .easeInOut
      case "easeIn" : curve = .easeIn
      case "easeOut": curve = .easeOut
      case "linear": curve = .linear
      default:
        damping = CGFloat(parse(numberFromString: args[1]).floatValue)
      }
      if damping.isNormal {
        return (.animator, UIViewPropertyAnimator(duration: duration,
                                                  dampingRatio: damping,
                                                  animations: nil))
      } else {
        return (.animator, UIViewPropertyAnimator(duration: duration,
                                                  curve: curve,
                                                  animations:nil))
      }
    }
    functions = [colorFunc, fontFunc, sysFontFunc, animatorFunc]
    #else
    functions = []
    #endif
  }
}

