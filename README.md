# YAS [![Swift](https://img.shields.io/badge/swift-4.*-orange.svg?style=flat)](#) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

<img src="docs/logo.png" width=150 alt="Logo" align=right />


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


# Credits:

Deps forked from:

* [yaml/libyaml](https://github.com/yaml/libyaml)
* [nicklockwood/Expression](https://github.com/nicklockwood/Expression)