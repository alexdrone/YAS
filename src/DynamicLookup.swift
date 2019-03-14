import Foundation

@dynamicMemberLookup
public struct RuleDynamicLookup {
  /// The style identifier.
  public let id: String
  /// Returns the current style definitions.
  public var style: [String: Rule] {
    guard let style = StylesheetManager.default.defs[id] else {
      warn("Unable to find style \(id).")
      return [:]
    }
    return style
  }

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
  /// Returns a `RuleDynamicLookup` pointing at the style passed as argument.
  public subscript(dynamicMember member: String) -> RuleDynamicLookup {
    return RuleDynamicLookup(id: member)
  }
}
