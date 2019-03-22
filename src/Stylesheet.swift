import Foundation

public enum ParseError: Error {
  /// The filename is not set.
  case fileNotSet
  /// The file was not found in the bundle.
  case fileNotFound(file: String)
  /// Illegal stylesheet format.
  case malformedStylesheetStructure(message: String?)
  /// Illegal stylesheet rule definition.
  case malformedRule(message: String)
}

public final class StylesheetManager {
  /// Reserved keywords.
  private struct Reserved {
    /// Root-level mapping used for cascade imports.
    static let importKeyword = "_import"
    /// Reserved property used for media queries.
    static let breakpointKeywork = "_breakpoint"
    /// Property prefix used for property animators.
    static let animatorPrefix = "_animator_"
    /// Used to define Styles with breakpoints.
    /// e.g.
    /// `Style: {foo: 1, bar: 2} # Container/default`
    /// `Style/small: {_breakpoint: ${horizontalSizeClass == compact}, foo: 42 } # Container/small`
    static let breakpointSeparator = "/"
  }
  /// Shared manager instance.
  public static let `default` = StylesheetManager()
  /// The style containers.
  private var styles: [String: Style] = [:]
  /// The reource bundle where the stylesheet is located.
  private var bundle: Bundle?

  init() {
    // Internal constructor.
  }

  // MARK: Public

  /// Returns the desired style.
  public func properties(
    forStyle style: String,
    context: Style.Context = Style.Context.default
  ) -> [String: Rule]? {
    return styles[style]?.properties(context: context)
  }

  /// Returns the rule named `name` of a specified style.
  public func property(
    style: String,
    name: String,
    context: Style.Context = Style.Context.default
  ) -> Rule? {
    return styles[style]?.property(named: name, context: context)
  }

  /// Returns the animator for a given property.
  /// Animators rule have the `animator-` prefix.
  /// e.g.
  /// layer.cornerRadius: 10
  /// animator-layer.cornerRadius: {_type: animator, curve: easeIn, duration: 1}
  public func animator(
    style: String,
    name: String,
    context: Style.Context = Style.Context.default
  ) -> Animator? {
    return styles[style]?.animator(named: name, context: context)
  }

  /// Parse and load the Yaml stylesheet.
  public func load(file: String, bundle: Bundle = Bundle.main) throws {
    try load(yaml: resolve(file: file, bundle: bundle))
    NotificationCenter.default.post(name: Notification.Name.StylesheetContextDidChange, object: nil)
  }

  /// Parses the markup content passed as argument.
  public func load(yaml string: String) throws {
    let startTime = CFAbsoluteTimeGetCurrent()

    // Parses the top level definitions.
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
      for imported in root.mapping![Reserved.importKeyword]?.array() ?? [] {
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
        guard key.string != Reserved.importKeyword else { continue }
        guard var defDic = value.mapping, let key = key.string else {
          throw ParseError.malformedStylesheetStructure(message:"A style should be a mapping.")
        }
        // Create the style container.
        var styleKey: String = key
        var breakpoint: String? = nil
        // Tries to parse the breakpoint.
        let components = key.components(separatedBy: Reserved.breakpointSeparator)
        if components.count == 2 {
          styleKey = components[0]
          breakpoint = components[1]
        }
        /// Retrieve the container.
        let style = styles[styleKey] ?? Style(identifier: styleKey)
        styles[styleKey] = style
        /// Adds the breakpoint if necessary.
        if let breakpoint = breakpoint, let expr = defDic[Reserved.breakpointKeywork]?.string {
          style.addBreakpoint(breakpoint, rawExpression: expr)
        }
        // In yaml definitions can inherit from others using the <<: *ID expression. e.g.
        // myDef: &_myDef
        //   foo: 1
        // myOtherDef: &_myOtherDef
        //   <<: *_myDef
        //   bar: 2
        if let inherit = defDic["<<"]?.mapping {
          for (ik, iv) in inherit {
            guard let _ik = ik.string else {
              throw ParseError.malformedStylesheetStructure(message: "Invalid key.")
            }
            style.addRule(
              try Rule(key: _ik, value: iv),
              property: _ik,
              breakpoint: breakpoint)
          }
        }
        // Properties.
        for (k, v) in defDic {
          guard let _k = k.string, _k != "<<", !_k.hasPrefix(Reserved.animatorPrefix) else {
            continue
          }
          style.addRule(
            try Rule(key: _k, value: v),
            property: _k,
            breakpoint: breakpoint)
        }
        // Animators.
        for (k, v) in defDic {
          guard let _k = k.string,  _k.hasPrefix(Reserved.animatorPrefix) else {
            continue
          }
          let pk = _k.replacingOccurrences(of: Reserved.animatorPrefix, with: "")
          style.addAnimator(
            try Rule(key: pk, value: v).animator,
            property: pk,
            breakpoint: breakpoint)
        }
      }
    }

    try resolveImports(string)
    try parseRoot(content)
    debugLoadTime("Stylesheet.load", startTime: startTime)
  }

  // MARK: Private

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
}
