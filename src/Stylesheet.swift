import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Shorthand for the stylesheet singleton.
public let S = StylesheetManager();

public enum ParseError: Error {
  /// Illegal format for the stylesheet.
  case malformedStylesheetStructure(message: String?)
  /// An illegal use of a `!!func` in the stylesheet.
  case illegalNumberOfArguments(function: String?)
}

public final class StylesheetManager {
  /// Singleton instance.
  public static let `default` = StylesheetManager()

  /// The stylesheet file currently loaded.
  private var file: String?
  /// The default debug remote fetch url.
  public var debugRemoteUrl: String = "http://localhost:8000/"
  /// The parsed *Yaml* document.
  public var defs: [String: [String: Rule]] = [:]
#if canImport(UIKit)
  /// The parent container size for the current context.
  public private(set) var parentSize: CGSize = .zero
  /// Available animators.
  public var animators: [String: [String: UIViewPropertyAnimator]] = [:]
#endif

  /// Returns the rule named 'name' of a specified style.
  public func rule(style: String, name: String) -> Rule? {
    return defs[style]?[name]
  }

  #if canImport(UIKit)
  /// Returns the rule named 'name' of a specified style.
  public func animator(style: String, name: String) -> UIViewPropertyAnimator? {
    return animators[style]?[name]
  }
  #endif

  private func loadFileFromRemoteServer(_ file: String) -> String? {
    guard let url = URL(string: "\(debugRemoteUrl)\(file).yaml") else { return nil }
    return try? String(contentsOf: url, encoding: .utf8)
  }

  private func loadFileFromBundle(_ file: String) -> String? {
    guard let leaf = file.components(separatedBy: "/").last else { return nil }
    guard let path = Bundle.main.path(forResource: leaf, ofType: "yaml") else { return nil }
    return try? String(contentsOfFile: path, encoding: .utf8)
  }

  private func resolve(file: String) -> String {
    #if targetEnvironment(simulator)
    if let content = loadFileFromRemoteServer(file) {
      return content
    } else if let content = loadFileFromBundle(file) {
      return content
    }
    #else
    if let content = loadFileFromBundle(file) {
      return content
    }
    #endif
    return ""
  }

  /// Loads the yaml stylesheet.
  public func load(file: String?) throws {
    if file != nil {
      self.file = file
    }
    guard let file = file ?? self.file else {
      print("nil filename.")
      return
    }
    try load(yaml: resolve(file: file))
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
        content += resolve(file: fileName)
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

  private func debugLoadTime(_ label: String, startTime: CFAbsoluteTime){
    let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    print(String(format: "\(label) (%2f) ms.", arguments: [timeElapsed]))
  }

}
