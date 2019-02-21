import Foundation

public class FuncExpr {
  /// Returns the rule function registry.
  static let registry = FuncExprRegistry.default

  /// Adds a new function to the registry.
  static func export(_ function: FuncExpr) {
    registry.functions.append(function)
  }

  /// Internal function tokens.
  struct Token {
    /// Function brackets.
    static let block = ("(", ")")
    /// Arguments delimiters.
    static let delimiter = (",")
  }

  /// The number of arguments required by this function.
  private let arity: Int
  /// The function name.
  private let name: String
  /// Evaluation function.
  private let eval: ([String]) -> (Rule.ValueType, Any?)

  public init(
    name: String,
    arity: Int,
    eval: @escaping ([String]) -> (Rule.ValueType, Any?)
  ) {
    self.name = name
    self.arity = arity
    self.eval = eval
  }

  private func sanitize(format: String) -> String? {
    let substring = format.trimmingCharacters(in: CharacterSet.whitespaces)
    guard substring.hasPrefix(name) else { return nil }
    guard
      substring.occurrences(of: Token.block.0) == 1,
      substring.occurrences(of: Token.block.1) == 1 else { return nil }
    guard substring.components(separatedBy: Token.delimiter).count == arity else {
      return nil
    }
    return substring
  }

  private func arguments(format: String) -> [String] {
    guard var string = sanitize(format: format) else { return [] }
    string = string
      .replacingOccurrences(of: name, with: "")
      .replacingOccurrences(of: Token.block.0, with: "")
      .replacingOccurrences(of: Token.block.1, with: "")
    return string.components(separatedBy: Token.delimiter)
  }

  /// Returns `true` if the function signature is compatible with the following function parser.
  func match(format: String) -> Bool {
    return sanitize(format: format) != nil
  }

  /// Evalutate the function.
  func evaluate(format: String) -> (Rule.ValueType, Any?) {
    let args = arguments(format: format)
    return eval(args)
  }
}

/// Returns the argument parsed as a `NSNumber`.
public func parse(numberFromString string: String) -> NSNumber {
  if let expr = parse(expressionFromString: string) {
    return NSNumber(value: (try? expr.evaluate()) ?? 0)
  } else {
    return NSNumber(value: (string as NSString).doubleValue)
  }
}

/// Returns the argumetn parsed as a `String`,
public func parse(expressionFromString string: String) -> Expression? {
  if let exprString = ConstExpr.sanitize(expression: string) {
    return ConstExpr.builder(exprString)
  }
  return nil
}

private extension String {
  /// Returns the occurences of a substring in this string.
  func occurrences(of string: String) -> Int {
    assert(!string.isEmpty)
    var count = 0
    var searchRange: Range<String.Index>?
    while let foundRange = range(of: string, options: [], range: searchRange) {
      count += 1
      searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
    }
    return count
  }
}
