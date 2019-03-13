import Foundation

/// Represents a rule for a style definition.
public class Rule: CustomStringConvertible {
  /// Internal value type store.
  public enum ValueType: String {
    case expression
    case bool
    case number
    case string
    case object
    case undefined
  }

  /// The key for this value.
  var key: String
  /// The value type.
  var type: ValueType?
  /// The computed value.
  var store: Any?

  /// Construct a rule from a Yaml subtree.
  init(key: String, value: YAMLNode) throws {
    self.key = key
    let (type, store) = try parseValue(for: value)
    (self.type, self.store) = (type, store)
  }

  /// Returns this rule evaluated as an integer.
  /// - note: The default value is 0.
  public var integer: Int {
    return (nsNumber as? Int) ?? 0
  }

  /// Returns this rule evaluated as a boolean.
  /// - note: The default value is `false`.
  public var bool: Bool {
    return (nsNumber as? Bool) ?? false
  }

  /// Returns this rule evaluated as a string.
  public var string: String {
    return cast(type: .string, default: String.init())
  }

  /// Object representation for the `rhs` value of this rule.
  public var object: AnyObject? {
    guard let type = type else { return NSObject() }
    switch type {
    case .bool, .number, .expression:
      return nsNumber
    case .string:
      return (string as NSString)
    case .object:
      return cast(type: .object, default: nil)
    default:
      return nil
    }
  }

  /// Returns the rule value as the desired return type.
  /// - note: The enum type should be backed by an integer store.
  public func `enum`<T: EnumRepresentable>(
    _ type: T.Type,
    default: T = T.init(rawValue: 0)!
  ) -> T {
    return T.init(rawValue: integer) ?? `default`
  }

  public func cast<T>(type: ValueType, default: T) -> T {
    /// There`s a type mismatch between the desired type and the type currently associated to this
    /// rule.
    guard self.type == type else {
      warn("type mismatch – wanted \(type), found \(String(describing: self.type)).")
      return `default`
    }
    /// Casts the store value as the desired type `T`.
    if let value = self.store as? T {
      return value
    }
    return `default`
  }

  /// Main entry point for numeric return types and expressions.
  /// - note: If it fails evaluating this rule value, `NSNumber` 0.\
  public var nsNumber: NSNumber {
    let `default` = NSNumber(value: 0)
    // If the store is an expression, it must be evaluated first.
    if type == .expression {
      let expression = cast(type: .expression, default: Rule.defaultExpression)
      return NSNumber(value: evaluate(expression: expression))
    }
    // The store is `NSNumber` obj.
    if type == .bool || type == .number, let nsNumber = store as? NSNumber {
      return nsNumber
    }
    return `default`
  }

  /// Tentatively tries to evaluate an expression.
  /// - note: Returns 0 if the evaluation fails.
  private func evaluate(expression: Expression?) -> Double {
    guard let expression = expression else {
      warn("nil expression.")
      return 0
    }
    do {
      return try expression.evaluate()
    } catch {
      warn("Unable to evaluate expression: \(expression.description).")
      return 0
    }
  }

  /// Parse the `rhs` value of a rule.
  private func parseValue(for yaml: YAMLNode) throws -> (ValueType, Any?) {
    if yaml.isScalar {
      if let v = yaml.bool {
        return(.bool, v) }
      if let v = yaml.int {
        return(.number, v)
      }
      if let v = yaml.float {
        return(.number, v)
      }
      if let v = yaml.string {
        let result = try parse(string: v)
        return (result.0, result.1)
      }
    }
    if let _ = yaml.mapping {
      return try parse(mapping: yaml)
    }
    return (.undefined, nil)
  }

  /// Parse a string value.
  /// - `${expression}` to evaluate an expression.
  /// - A string.
  private func parse(string: String) throws -> (ValueType, Any?) {
    // - `${expression}` to evaluate an expression.
    if let exprString = ConstExpr.sanitize(expression: string) {
      return (.expression, ConstExpr.builder(exprString))
    }
    return (.string, string)
  }

  /// Parse an object.
  private func parse(mapping: YAMLNode) throws -> (ValueType, Any?) {
    guard mapping.isMapping else {
      return (.undefined, nil)
    }
    return ObjectExprRegistry.default.eval(fromYaml:mapping)
  }

  /// A textual representation of this instance.
  public var description: String {
    return type?.rawValue ?? "undefined"
  }

  static private let defaultExpression = Expression("0")
}
