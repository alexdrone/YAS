# YAS [![Swift](https://img.shields.io/badge/swift-4.*-orange.svg?style=flat)](#) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

<img src="docs/logo.png" width=150 alt="Logo" align=right />

**YAS** is YAML-based stylesheet engine written in Swift.

### Installing the framework

```
cd {PROJECT_ROOT_DIRECTORY}
curl "https://raw.githubusercontent.com/alexdrone/YAS/master/bin/dist.zip" > dist.zip && unzip dist.zip && rm dist.zip;
```

Drag `YAS.framework` in your project and add it as an embedded binary.

If you use [xcodegen](https://github.com/yonaskolb/XcodeGen) add the framework to your *project.yml* like so:

```
targets:
  YOUR_APP_TARGET:
    ...
    dependencies:
      - framework: PATH/TO/YOUR/DEPS/YAS.framework
```

### Getting Started

Let's create a very basic YAML stylesheet and save it in a file named `style.yaml`.

```
FooStyle:
  backgroundColor: color(ff0000)
  margin: 10.0
```

Load it up and use it in your Swift code:

```
try! Yas.manager.load("style.yaml")
let margin = Yas.lookup.FooStyle.margin //10.0
let backgroundColor = Yas.lookup.FooStyle.backgroundColor //UIColor(...)
```

Apply a style to a `UIView`:

```
view.apply(style: Yas.lookup.FooStyle)
```

### Primitives

```
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
  # Functions.
  # New functions can be exported by calling FuncExpr.export(...)
  # `color(string [color hexcode])`: Returns a color.
  color: "color(#ff0000)"
  # `font(string [font name or `system`], number [point size])`
  font: font(Arial,42)
  # `systemfont(number [point size], weight [ultralight, thin, ..., black])`
  systemFont: systemfont(12,bold)
  # `animator(number [duration], string [easeIn, easeOut, easeInOut, linear])` or
  # `animator(number [duration], number [damping])`
  animator1: animator(1,easeIn)
```

### References and anchors

By using YAML anchors and references you can reuse values across your stylesheet:

```
Foo:
  fooValue: &_fooValue 42.0
Bar
  bar: *_fooValue
  baz: 2
```

You can also copy the whole style using the YAML extension construct:

```
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