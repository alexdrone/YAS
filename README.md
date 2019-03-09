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
  backgroundColor: {type: color, hex: ff0000}
  margin: 10.0
```

Load it up and access to its member using the built-in dynamic lookup proxy.

```swift
try! YAMLStylesheet.manager.load("style.yaml")
let margin = YAMLStylesheet.lookup.FooStyle.margin.cgFloat //10.0
let backgroundColor = YAMLStylesheet.lookup.FooStyle.backgroundColor.color //UIColor(...)
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
  # New object types can be exported by calling ObjectExpr.export(...)
  # {type: color, hex: ffffff, (darken: [0-100]), (lighten: [0-100]), (alpha: [0-1])}
  color: {type: color, hex: ff0000}
  # {type: font, (name: [fontname]), size: [size], (weight: [light...])}
  font:  {type: font, name: Arial, size: 42}
  fontWeight: {type: font, weight: bold, size: 12}
  # {type: animator, duration: 1, (curve: [easeIn...]), (damping: [0-1])}
  animator: {type: animator, curve: easeIn, duration: 1}
  # {type: attributedString,  (name: [fontname]), size: [size], (weight: [light...]), (kern: [0..n]), (hex: [hex colorcode]), (supportDynamicType: [bool])}
  attributedString: {type: attributedString, name: Arial, size: 42, kern: 2, hex: ff0000}
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
  someColor: color(#cacaca)
Bar:
  <<: *_Foo
  yetAnotherValue: 2
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
ObjectExprRegistry.default.export(ObjectExprFactory(
  type: MyCustomObjectExpression.self,
  name: "myObject",
  ruleType: .object))
```

Use your custom define object expression in any stylesheet rule.

```yaml

MyStyle:
  myCustomRule: {type: myObject, foo: 42, bar: "Hello"}
```

### Reacting to stylesheet changes

`Notification.Name.YAMLStylesheetDidChange` is posted whenever the stylesheet has been reloaded.

### Dependencies and credits

Deps forked from:

* [yaml/libyaml](https://github.com/yaml/libyaml)
* [nicklockwood/Expression](https://github.com/nicklockwood/Expression)
