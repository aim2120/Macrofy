# Macrofy

A Swift macro package that automatically generates property-wrapper-equivalent macros from property wrapper types.

## Overview

Macrofy simplifies the creation of property wrapper macros by automatically generating the macro expansion logic for your property wrappers.
You can simply add `@macrofy` to your `@propertyWrapper` declaration to generate a macro that can be used in place of your property wrapper in code!

## Motivation

In Swift 6 language mode, property wrappers introduce problematic behavior due to their [inability to support `Sendable` types](https://forums.swift.org/t/property-wrappers-in-sendable-classes/77535).
Since Apple has not yet introduced a solution for this problem, a natural solution is to pursue macro usage in place of property wrappers.
Unfortunately, macros are more difficult and verbose to implement than property wrappers.
This library hopes to make that process easier by using your existing property wrappers to generate equivalent macros.

## Features

- **Automatic macro generation**: Transform any property wrapper into a macro with a single annotation (and a little boilerplate)
- **Drop-in equivalency**: The macro expansion implementation adjusts to your property wrapper type, considering settability and project values
- **Flexible customization**: Protocol-based APIs allow for further customization and fine-tuning when needed

## Usage

### (Optional) Step 0: Create a macro SPM package

_Even if you have an existing package, this can be useful to create the boilerplate needed for macros._

```sh
$ swift package init --type macro
```

For the sake of this example, we assume the following structure:
```sh
MyWrapper/ # SPM package
└── Sources/
    ├── MyWrapperMacro # library target
    └── MyWrapperMacroInternal # macro target
```

### Step 1: Add the `@macrofy` macro to your property wrapper declaration

Location: `MyWrapperMacroInternal`

> [!NOTE]  
> Currently, this must be done in a `macro` target (NOT a library target).
> In the future, we may aim to allow for the macro to be used in library targets, but this requires further development.

```swift
import Macrofy
// swift syntax imports are needed for the macro
import SwiftSyntax
import SwiftSyntaxMacros

@macrofy
@propertyWrapper
public struct MyWrapper<Value: Sendable>: Sendable {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public let wrappedValue: Value
}

// Generates `MyWrapperMacro`
```

### Step 2: Add a macro plugin

Location: `MyWrapperMacroInternal`

```swift
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyWrapperMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [MyWrapperMacro.self]
}
```

### Step 3: Declare your macro in a library target

Location: `MyWrapperMacro`

```swift
@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro MyWrapper(
    _ arguments: Any...
) = #externalMacro(module: "MyWrapperMacroInternal", type: "MyWrapperMacro")
```

### Step 4: Use your macro in place of your property wrapper

```swift
import MyWrapperMacro

final class Service: Sendable {
    @MyWrapper var value: String = "I'm a macro!"
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
