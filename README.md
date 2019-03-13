# YAS [![Swift](https://img.shields.io/badge/swift-4+-orange.svg?style=flat)](#) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

<img src="docs/logo.png" width=150 alt="Logo" align=right />

**YAS** is a YAML-based stylesheet engine written in Swift.

### Installing the framework

```bash
cd {PROJECT_ROOT_DIRECTORY}
curl "https://raw.githubusercontent.com/alexdrone/YAS/master/bin/dist.zip" > dist.zip && unzip dist.zip && rm dist.zip;
```

Drag `YAS.framework` in your project and add it as an embedded binary.

If you are using [xcodegen](https://github.com/yonaskolb/XcodeGen) add the framework to your *project.yml* like so:

```yaml
targets:
  YOUR_APP_TARGET:
    ...
    dependencies:
      - framework: PATH/TO/YOUR/DEPS/YAS.framework
```

If you are using **Carthage**:
Add the following line to your `Cartfile`:

```ruby
github "alexdrone/YAS" "master"    
```

### Getting Started

Create a new YAML stylesheet and save it in a file named `style.yaml`.

```yaml
FooStyle:
  backgroundColor: {_type: color, hex: ff0000}
  margin: 10.0
```

Load it up and access to its member using the built-in dynamic lookup proxy.

```swift
try! StylesheetContext.manager.load("style.yaml")
let margin = StylesheetContext.lookup.FooStyle.margin.cgFloat //10.0
let backgroundColor = StylesheetContext.lookup.FooStyle.backgroundColor.color //UIColor(...)
```

or automatically apply the style to your `UIView`:

```swift
view.apply(style: Yas.lookup.FooStyle)
```

### Built-in types

```yaml
Example:
  cgFloat: 42.0
  bool: true
  integer: 42
  # Symbols can be exported by calling ConstExpr.export([:])
  enum: ${NSTextAlignment.right}
  # ${...} is the expression delimiter
  cgFloatExpression: ${41+1}
  boolExpression: ${1 == 1 && true}
  integerExpression: ${41+1}
  # Custom objects.
  # Use the reserved _type attribute to distinguish the object type.
  # New object types can be exported by calling ObjectExpr.export(...)
  # {_type: color, hex: ffffff, (darken: [0-100]), (lighten: [0-100]), (alpha: [0-1])}
  color: {_type: color, hex: ff0000}
  # {_type: font, (name: [fontname]), size: [size], (weight: [light...])}
  font:  {_type: font, name: Arial, size: 42}
  fontWeight: {_type: font, weight: bold, size: 12}
  # {_type: animator, duration: 1, (curve: [easeIn...]), (damping: [0-1])}
  animator: {_type: animator, curve: easeIn, duration: 1}
  # {_type: text,  (name: [fontname]), size: [size], (weight: [light...]), (kern: [0..n]), (hex: [hex colorcode]), (supportDynamicType: [bool])}
  textStyle: {_type: text, name: Arial, size: 42, kern: 2, hex: ff0000}
```

### References and anchors

By using YAML anchors and references you can reuse values across your stylesheet:

```yaml
Foo:
  fooValue: &_fooValue 42.0
Bar:
  bar: *_fooValue
  baz: 2
```

You can also copy the whole style using the YAML extension construct:

```yaml
Foo: &_Foo
  aValue: 42.0
  anotherValue: "Hello"
  someColor: {_type: color, hex: ff0000}
Bar:
  <<: *_Foo
  yetAnotherValue: 2
```

#### Real life example

```yaml
Palette:
  primaryColorHex: &_primaryColorHex ff0000
  primaryColor: &_primaryColor {_type: color, hex: *_primaryColorHex}
  primaryColor600: &_primaryColor600 {_type: color, hex: *_primaryColorHex, darken: 10}
  primaryColor700: &_primaryColor700 {_type: color, hex: *_primaryColorHex, darken: 20}
Typography:
  primaryFontName: &_primaryFontName "Open Sans"
  secondaryFontName: &_secondaryFontName "Rubik"
  body1: &_body1 {_type: attributedString, name: *_secondaryFontName, size: 14.26, kern: 0.25, color: *_primaryColorHex}
  body2: &_body2 {_type: attributedString, weight: medium, size: 12.22, kern: 0.5, color: *_primaryColorHex}
LandingPage:
  titleText: *_body1
  backgroundColor: *_primaryColor600
  topMargin: 12
  shouldHideHero: ${horizontalSizeClass == compact}
  tileSize: ${screenSize.width/2 - 8}  

```

### Cascade imports

Stylesheets can be split into smaller modules by using the `import` rule at the top of the main stylesheet file.

```yaml

import: [typography.yaml, palette.yaml, buttons.yaml]

```

### Custom types

You can define your own custom object expressions by creating a new `ObjectExpr`
subclass.

```swift

@objc class MyCustomObjectExpression : ObjectExprBase {
  // Your arguments must be marked with @obj and dynamic.
  @objc dynamic var foo: Int = 0
  @objc dynamic var bar: String = ""

  override func eval() -> Any? {
    // Build your desired return types
    return MyCustomObject(foo: foo, bar: bar)
  }
}
```

Finally register your `ObjectExpr` in the shared `ObjectExprRegistry`.

```swift
StylesheetContext.objectExpr.export(ObjectExprFactory(
  type: MyCustomObjectExpression.self,
  name: "myObject")
```

Use your custom define object expression in any stylesheet rule.

```yaml

MyStyle:
  myCustomRule: {_type: myObject, foo: 42, bar: "Hello"}
```

### Reacting to stylesheet changes

`Notification.Name.StylesheetContextDidChange` is posted whenever the stylesheet has been reloaded.

### Dependencies and credits

Deps forked from:

* [yaml/libyaml](https://github.com/yaml/libyaml)
* [nicklockwood/Expression](https://github.com/nicklockwood/Expression)
