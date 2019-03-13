import Foundation

@dynamicMemberLookup
public struct RuleDynamicLookup {
  /// The style name.
  public let id: String
  /// Returns the current style.
  public var style: [String: Rule] {
    guard let style = StylesheetManager.default.defs[id] else {
      warn("Unable to find style \(id).")
      return [:]
    }
    return style
  }

  /// Builds a dynamic lookup with the given style.
  init(id: String) {
    self.id = id
  }

  public subscript(dynamicMember member: String) -> Rule {
    let manager = StylesheetManager.default
    guard let rule = manager.rule(style: id, name: member) else {
      fatalError("error: \(id) does not declare \(member) as a property.")
    }
    return rule
  }
}

@dynamicMemberLookup
public struct StyleDynamicLookup  {
  public subscript(dynamicMember member: String) -> RuleDynamicLookup {
    return RuleDynamicLookup(id: member)
  }
}
