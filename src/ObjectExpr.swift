import Foundation

/// The arguments of this object props.
public protocol ObjectExpr: NSObjectProtocol {
  init()
  /// The result of this object expression.
  func eval() -> Any?
}

@objc open class ObjectExprBase: NSObject, ObjectExpr {
  public required override init() {}

  public func eval() -> Any? {
    return nil
  }
}

public protocol ObjectExprFactoryProtocol {
  /// The object name.
  var name: String { get }
  /// The return type for this compound.
  var returnType: Rule.ValueType { get }
  /// Build a new argument object.
  func build() -> ObjectExpr
}

public final class ObjectExprRegistry {
  /// Singleton instance.
  static let `default` = ObjectExprRegistry()
  /// The objects factories registered.
  private var factories: [ObjectExprFactoryProtocol] = []
  /// All of the registered `_type` identifiers.
  lazy var exportedObjectTypes: [String] = {
    return factories.map { factory in factory.name }
  }();

  private init() {
    objectExprRegisterDefaults(self)
  }

  /// Adds a new function to the registry.
  public func export(_ object: ObjectExprFactoryProtocol) {
    factories.append(object)
  }

  /// Tentatively returns the value for a registered object expression.
  func eval(fromYaml yaml: YAMLNode) -> (Rule.ValueType, Any?) {
    guard let factory = factory(fromYaml: yaml), let object = object(fromYaml: yaml) else {
      return (.undefined, nil)
    }
    return (factory.returnType, object.eval())
  }

  private func factory(fromYaml yaml: YAMLNode) -> ObjectExprFactoryProtocol? {
    guard yaml.isMapping,
      let type = yaml.mapping?[Rule.Reserved.type]?.string else {
        return nil
    }
    guard let objectFactory = factories.filter({ $0.name == type }).first else {
      return nil
    }
    return objectFactory
  }

  private func object(fromYaml yaml: YAMLNode) -> ObjectExpr? {
    guard let factory = factory(fromYaml: yaml) else {
      return nil
    }
    let object = factory.build()
    let nsObject = object as? NSObject

    for (k, v) in yaml.mapping! {
      guard v.isScalar, let key = k.string, key != Rule.Reserved.type else {
        continue
      }
      YASObjcExceptionHandler.try({
        if let value = v.bool {
          nsObject?.setValue(NSNumber(value: value), forKey: key)
        }
        if let value = v.int {
          nsObject?.setValue(NSNumber(value:value), forKey: key)
        }
        if let value = v.float {
          nsObject?.setValue(NSNumber(value: value), forKey: key)
        }
        if let value = v.string {
          nsObject?.setValue(value, forKey: key)
        }
      }, catchAndRethrow: nil, finallyBlock: nil)
    }
    return object
  }
}

public class ObjectExprFactory<T: ObjectExpr>: ObjectExprFactoryProtocol {
  public let name: String
  public let returnType: Rule.ValueType
  private let builder: () -> T

  public init(
    type: T.Type,
    name: String,
    builder: @escaping () -> T
  ) {
    self.name = name
    self.returnType = Rule.ValueType.object
    self.builder = builder
  }

  public func build() -> ObjectExpr {
    return builder()
  }
}
