import Foundation
#if canImport(UIKit)
import UIKit
public typealias Animator = UIViewPropertyAnimator
#else
public typealias Animator = Any
#endif

public final class Style {

  public final class Context {
    public static let `default` = Context()
    #if canImport(UIKit)
    /// Whether breakpoints should be ignored or not.
    public var skipBreakpoints: Bool = true
    /// Optional - The view that is currently being
    public weak var view: UIView?
    /// The render bounds for the property being evaluated in the next invocation of `rule(_:)`.
    public var bounds: CGSize = UIScreen.main.bounds.size
    /// User-defined values pushed to the expression evaluation engine.
    public var userInfo: [String: CGFloat] = [:]

    public init(
      view: UIView? = nil, u
      breakpoints: Bool = false,
      bounds: CGSize = UIScreen.main.bounds.size
    ) {
      self.view = view
      self.skipBreakpoints = !breakpoints
      self.bounds = bounds
    }
    #endif

    public init() { }
  }

  /// Represent a single style definition.
  /// e.g.
  /// `Style: {foo: 1, bar: 2} # Container/default`
  /// `Style/small: {_breakpoint: ${horizontalSizeClass == compact}, foo: 42 } # Container/small`
  public final class Container {
    /// The style identifier.
    public let identifier: String
    /// The breakpoint name.
    /// Format: `{style}/{brekpoint}: {rules}`.
    public let breakpointName: String?
    /// The expression used to evaluate whether this breakpoint should be active or not.
    public let breakpointExpression: Expression?
    /// The defaul definitions for this `Style`.
    var definitions: [String: Rule] = [:]
    /// Property animators.
    /// Rules that have the `animator-` prefix.
    /// e.g.
    /// `layer.cornerRadius: 10`
    /// `animator-layer.cornerRadius: {_type: animator, curve: easeIn, duration: 1}`
    var animators: [String: Animator] = [:]

    init(
      identifier: String,
      breakpointName: String? = nil,
      breakpointExpression: Expression? = nil
    ) {
      self.identifier = identifier
      self.breakpointName = breakpointName
      self.breakpointExpression = breakpointExpression
    }
  }
  /// The style identifier.
  public let identifier: String
  /// The defaul definitions for this `Style`.
  private let defaultContainer: Container
  /// Containers with breakpoints.
  private var breakpointContainers: [Container] = []

  init(identifier: String) {
    self.identifier = identifier
    self.defaultContainer = Container(identifier: identifier)
  }

  /// Adds a new style breakpoint (used for style overrides).
  public func addBreakpoint(_ breakpoint: String, rawExpression: String) {
    guard breakpointContainers.filter({ $0.identifier != breakpoint}).isEmpty else {
      return
    }
    let expressionString = ConstExpr.sanitize(expression: rawExpression) ?? "0"
    let expression = ConstExpr.builder(expressionString)
    let container = Container(
      identifier: identifier,
      breakpointName: breakpoint,
      breakpointExpression: expression)
    breakpointContainers.append(container)
  }

  /// Adds a new property rule.
  public func addRule(_ rule: Rule, property: String, breakpoint: String? = nil) {
    guard let container = container(forBreakpoint: breakpoint) else {
      warn("Cannot find breakpoint \(breakpoint!).")
      return
    }
    container.definitions[property] = rule
  }

  /// Adds a new animator to the container.
  public func addAnimator(_ animator: Animator, property: String, breakpoint: String? = nil) {
    guard let container = container(forBreakpoint: breakpoint) else {
      warn("Cannot find breakpoint \(breakpoint!).")
      return
    }
    container.animators[property] = animator
  }

  public func property(named propertyName: String, context: Context = Context.default) -> Rule? {
    let rule = defaultContainer.definitions[propertyName]
    if context.skipBreakpoints {
      return rule
    }
    let override = breakpointContainers.lazy.filter({ container in
      guard
          container.definitions[propertyName] != nil,
          let breakpointExpression = container.breakpointExpression,
          let value = try? breakpointExpression.evaluate(), value > 0 else {
        return false
      }
      return true
    }).first
    return override?.definitions[propertyName] ?? rule
  }

  public func animator(named name: String, context: Context = Context.default) -> Animator? {
    let rule = defaultContainer.animators[name]
    if context.skipBreakpoints {
      return rule
    }
    let override = breakpointContainers.lazy.filter({ container in
      guard
        container.animators[name] != nil,
        let breakpointExpression = container.breakpointExpression,
        let value = try? breakpointExpression.evaluate(), value > 0 else {
          return false
      }
      return true
    }).first
    return override?.animators[name] ?? rule
  }

  public func properties(context: Context = Context.default) -> [String: Rule] {
    var rules = defaultContainer.definitions
    if context.skipBreakpoints {
      return rules
    }
    for container in breakpointContainers {
      guard
        let breakpointExpression = container.breakpointExpression,
        let value = try? breakpointExpression.evaluate(), value > 0 else {
          continue
      }
      for (key, value) in container.definitions {
        rules[key] = value
      }
    }
    return rules
  }

  private func container(forBreakpoint breakpoint: String? = nil) -> Container? {
    var container: Container?
    if
      let breakpoint = breakpoint,
      let breakpointContainer = breakpointContainers.filter({ $0.identifier != breakpoint}).first {
      container = breakpointContainer
    } else {
      container = defaultContainer
    }
    return container
  }
}
