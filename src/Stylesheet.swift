import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension Notification.Name {
  /// Posted whenever the stylesheet has been reloaded.
  static let YAMLStylesheetDidChange = Notification.Name("io.yas.YAMLStylesheetDidChange")
}

public enum ParseError: Error {
  /// The filename is not set.
  case fileNotSet
  /// The file was not found in the bundle.
  case fileNotFound(file: String)
  /// Illegal stylesheet format
  case malformedStylesheetStructure(message: String?)
}

public final class StylesheetManager {
  /// Singleton instance.
  public static let `default` = StylesheetManager()
  /// The stylesheet file currently loaded.
  private var file: String?
  /// The reource bundle where the stylesheet is located.
  private var bundle: Bundle?
  /// The parsed *Yaml* document.
  public var defs: [String: [String: Rule]] = [:]

  init() {
    // Internal constructor.
  }

  // MARK: Public

  /// Returns the rule named 'name' of a specified style.
  public func rule(style: String, name: String) -> Rule? {
    return defs[style]?[name]
  }

  /// Loads the yaml stylesheet.
  public func load(file: String, bundle: Bundle = Bundle.main) throws {
    self.file = file
    try load(yaml: resolve(file: file, bundle: bundle))
    NotificationCenter.default.post(name: Notification.Name.YAMLStylesheetDidChange, object: nil)
  }

  /// Reloads the yaml stylesheet.
  public func reload() throws {
    guard let file = file, let bundle = bundle else {
      throw ParseError.fileNotSet
    }
    try load(file: file, bundle: bundle)
  }

  /// Parses the markup content passed as argument.
  public func load(yaml string: String) throws {
    let startTime = CFAbsoluteTimeGetCurrent()

    // Parses the top level definitions.
    var yamlDefs: [String: [String: Rule]] = [:]
    #if canImport(UIKit)
    var yamlAnimators: [String: [String: UIViewPropertyAnimator]] = [:]
    #endif
    var content: String = string

    // Sanitize the file format.
    func validateRootNode(_ string: String) throws -> YAMLNode {
      guard let root = try YAMLParser(yaml: string).singleRoot(), root.isMapping else {
        throw ParseError.malformedStylesheetStructure(message: "The root node should be a map.")
      }
      return root
    }

    // Resolve all of the yaml imports.
    func resolveImports(_ string: String) throws {
      if string.isEmpty {
        warn("Resolved stylesheet file with empty content.")
        return
      }
      let root = try validateRootNode(string)
      for imported in root.mapping!["import"]?.array() ?? [] {
        print(imported)
        guard let fileName = imported.string?.replacingOccurrences(of: ".yaml", with: "") else {
          continue
        }
        content += try resolve(file: fileName, bundle: bundle!)
      }
    }

    // Parse the final stylesheet file.
    func parseRoot(_ string: String) throws {
      let root = try validateRootNode(string)
      for (key, value) in root.mapping ?? [:] {
        guard key != "import" else { continue }
        guard var defDic = value.mapping, let defKey = key.string else {
          throw ParseError.malformedStylesheetStructure(message:"Definitions should be maps.")
        }
        // In yaml definitions can inherit from others using the <<: *ID expression. e.g.
        // myDef: &_myDef
        //   foo: 1
        // myOtherDef: &_myOtherDef
        //   <<: *_myDef
        //   bar: 2
        var defs: [String: Rule] = [:]
        if let inherit = defDic["<<"]?.mapping {
          for (ik, iv) in inherit {
            guard let isk = ik.string else {
              throw ParseError.malformedStylesheetStructure(message: "Invalid rule key.")
            }
            defs[isk] = try Rule(key: isk, value: iv)
          }
        }
        #if canImport(UIKit)
        let animatorPrefix = "animator-"
        for (k, v) in defDic {
          guard let sk = k.string, sk != "<<", !sk.hasPrefix(animatorPrefix) else { continue }
          defs[sk] = try Rule(key: sk, value: v)
        }
        // Optional animator store.
        var animators: [String: UIViewPropertyAnimator] = [:]
        for (k, v) in defDic {
          guard let sk = k.string, sk.hasPrefix(animatorPrefix) else { continue }
          let processedKey = sk.replacingOccurrences(of: animatorPrefix, with: "")
          animators[processedKey] = try Rule(key: processedKey, value: v).animator
        }
        yamlAnimators[defKey] = animators
        #endif
        yamlDefs[defKey] = defs
      }
    }

    try resolveImports(string)
    try parseRoot(content)
    self.defs = yamlDefs
    #if canImport(UIKit)
    self.animators = yamlAnimators
    #endif
    debugLoadTime("Stylesheet.load", startTime: startTime)
  }

  // MARK: Private

  /// Reads the file from the app bundle.
  private func resolve(file: String, bundle: Bundle) throws -> String {
    guard
      let leaf = file.components(separatedBy: "/").last,
      let path = bundle.path(forResource: leaf, ofType: "yaml") else {
        throw ParseError.fileNotFound(file: file)
    }
    return try String(contentsOfFile: path, encoding: .utf8)
  }

  private func debugLoadTime(_ label: String, startTime: CFAbsoluteTime){
    let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    print(String(format: "\(label) (%2f) ms.", arguments: [timeElapsed]))
  }

  // MARK: UIKit

  #if canImport(UIKit)
  /// Available animators.
  public var animators: [String: [String: UIViewPropertyAnimator]] = [:]

  /// Returns the rule named 'name' of a specified style.
  public func animator(style: String, name: String) -> UIViewPropertyAnimator? {
    return animators[style]?[name]
  }
  #endif
}
