import XCTest
import UIKit
@testable import YAS

class StylesheetTests: XCTestCase {

  let test: String = "Test"
  var parser: StylesheetManager = StylesheetManager()

  override func setUp() {
    parser = StylesheetManager()
    try! parser.load(yaml: standardDefs)
  }

  func testCGFloat() {
    XCTAssert(parser.rule(style: test, name: "cgFloat")?.cgFloat == 42.0)
  }

  func testBool() {
    XCTAssert(parser.rule(style: test, name: "bool")?.bool == true)
  }

  func testInt() {
    XCTAssert(parser.rule(style: test, name: "integer")?.integer == 42)
  }

  func testCGFloatExpression() {
    XCTAssert(parser.rule(style: test, name: "cgFloatExpr")?.cgFloat == 42.0)
  }

  func testBoolExpression() {
    XCTAssert(parser.rule(style: test, name: "boolExpr")?.bool == true)
  }

  func testIntExpression() {
    XCTAssert(parser.rule(style: test, name: "integerExpr")?.integer == 42)
  }

  func testConstExpression() {
    XCTAssert(parser.rule(style: test, name: "const")?.cgFloat == 320)
  }

  func testColor() {
    let value = parser.rule(style: test, name: "color")?.color
    XCTAssert(value!.cgColor.components![0] == 1)
    XCTAssert(value!.cgColor.components![1] == 0)
    XCTAssert(value!.cgColor.components![2] == 0)
  }

  func testFont() {
    let value = parser.rule(style: test, name: "font")?.font
    XCTAssert(value!.pointSize == 42.0)
  }

  func testFontWeight() {
    let value = parser.rule(style: test, name: "fontWeight")?.font
    XCTAssert(value!.pointSize == 12.0)
  }

  func testEnum() {
    XCTAssert(parser.rule(style: test, name: "enum")?.enum(NSTextAlignment.self) == .right)
  }

  func testApplyStyleseetToView() {
    try! YAMLStylesheet.manager.load(yaml: viewDefs)
    let view = UIView()
    view.apply(style: YAMLStylesheet.manager.defs["View"])
    let value = view.backgroundColor
    XCTAssert(value!.cgColor.components![0] == 1)
    XCTAssert(value!.cgColor.components![1] == 0)
    XCTAssert(value!.cgColor.components![2] == 0)
    XCTAssert(view.layer.borderWidth == 1)
  }

  func testRefValues() {
    XCTAssert(parser.rule(style: test, name: "cgFloat")?.cgFloat == 42.0)
    XCTAssert(parser.rule(style: test, name: "refValue")?.cgFloat == 42.0)
  }

  func testInheritance() {
    XCTAssert(parser.rule(style: "Foo", name: "foo")?.cgFloat == 1)
    XCTAssert(parser.rule(style: "Bar", name: "foo")?.cgFloat == 1)
    XCTAssert(parser.rule(style: "Bar", name: "bar")?.cgFloat == 2)
  }

  func testTransition() {
    XCTAssert(parser.rule(style: test, name: "animator1")?.animator.duration == 1)
  }

  func testStyleDynamicLookup() {
    try! YAMLStylesheet.manager.load(yaml: viewDefs)
    let view = UIView()
    view.apply(style: YAMLStylesheet.lookup.View.style)
    XCTAssert(view.layer.borderWidth == 1)
  }

  func testRuleDynamicLookup() {
    try! YAMLStylesheet.manager.load(yaml: viewDefs)
    XCTAssert(YAMLStylesheet.lookup.View.margin.cgFloat == 10.0)
    XCTAssert(YAMLStylesheet.lookup.View.someText.string == "Aaa")
  }
}

let standardDefs = """
Test:
  cgFloat: &_cgFloat 42
  refValue: *_cgFloat
  bool: true
  integer: 42
  enum: ${NSTextAlignment.right}
  cgFloatExpr: ${41+1}
  boolExpr: ${1 == 1 && true}
  integerExpr: ${41+1}
  const: ${iPhoneSE.width}
  color: {type: color, hex: ff0000}
  font: {type: font, name: Arial, size: 42}
  fontWeight: {type: font, weight: bold, size: 12}
  animator1: {type: animator, curve: easeIn, duration: 1}
Foo: &_Foo
  foo:  1
Bar:
  <<: *_Foo
  bar: 2
"""

let fooDefs = """
Foo:
  bar: 42
  baz: ${41+1}
  bax: true
"""
let viewDefs = """
View:
  backgroundColor: {type: color, hex: ff0000}
  layer.borderWidth: 1
  flexDirection: ${row}
  margin: 10
  width_percentage: 100
  customNonApplicableProperty: 42
  someText: "Aaa"
"""
//#endif
