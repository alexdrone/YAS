# YAS [![Swift](https://img.shields.io/badge/swift-4.*-orange.svg?style=flat)](#) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

<img src="docs/logo.png" width=150 alt="Logo" align=right />

**YAS** is YAML-based stylesheet engine written in Swift.

### Installing the framework

```bash
cd {PROJECT_ROOT_DIRECTORY}
curl "https://raw.githubusercontent.com/alexdrone/YAS/master/bin/dist.zip" > dist.zip && unzip dist.zip && rm dist.zip;
```

Drag `YAS.framework` in your project and add it as an embedded binary.

If you use [xcodegen](https://github.com/yonaskolb/XcodeGen) add the framework to your *project.yml* like so:

```yaml
targets:
  YOUR_APP_TARGET:
    ...
    dependencies:
      - framework: PATH/TO/YOUR/DEPS/YAS.framework
```

### Getting Started

Let's create a very basic YAML stylesheet and save it in a file named `style.yaml`.

```yaml
FooStyle:
  backgroundColor: color(ff0000)
  margin: 10.0
```

Load it up and use it in your Swift code:

```swift
try! Yas.manager.load("style.yaml")
let margin = Yas.lookup.FooStyle.margin //10.0
let backgroundColor = Yas.lookup.FooStyle.backgroundColor //UIColor(...)
```

Apply a style to a `UIView`:

```swift
view.apply(style: Yas.lookup.FooStyle)
```

### Primitives

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
  # Custom objects..
  # New functions can be exported by calling ObjectExpr.export(...)
  # {type: color, hex: ffffff, (darken: [0-100]), (lighten: [0-100]), (alpha: [0-1])}
  color: {type: color, hex: ff0000}
  # {type: font, (name: [fontname]), size: [size], (weight: [light...])}
  font:  {type: font, name: Arial, size: 42}
  fontWeight: {type: font, weight: bold, size: 12}
  # {type: animator, duration: 1, (curve: [easeIn...]), (damping: [0-1])}
  animator1: {type: animator, curve: easeIn, duration: 1}
```

### References and anchors

By using YAML anchors and references you can reuse values across your stylesheet:

```yaml
Foo:
  fooValue: &_fooValue 42.0
Bar
  bar: *_fooValue
  baz: 2
```

You can also copy the whole style using the YAML extension construct:

```yaml
Foo: &_Foo
  aValue: 42.0
  anotherValue: "Hello"
  someColor: color(#cacaca)
Bar
  <<: *_Foo
  yetAnotherValue: 2
```

# Credits:

Deps forked from:

* [yaml/libyaml](https://github.com/yaml/libyaml)
* [nicklockwood/Expression](https://github.com/nicklockwood/Expression)
