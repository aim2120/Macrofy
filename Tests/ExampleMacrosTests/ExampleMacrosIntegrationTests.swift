//
//  ExampleMacrosIntegrationTests.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation

import Testing

import ExampleMacros
import Examples

@Suite
struct ExampleMacrosIntegrationTests {
    @Test func propertyWrapperExposedCorrectly() {
        let e1 = Example1()
        let e2 = Example2()
        let e3 = Example3()
        let e4 = Example4()
        let e5 = Example5()
        let e6 = Example6()

        #expect(e1.wrappedValue == randomID)
        #expect(e1.wrappedValue2 == randomID)
        #expect(e2.wrappedValue == randomID)
        #expect(e3.wrappedValue == randomID)
        #expect(e4.wrappedValue == randomID)
        #expect(e5.wrappedValue == randomID)
        #expect(e6.wrappedValue == randomID)

        #expect(e1.propertyWrapper.wrappedValue == randomID)
        #expect(e1.propertyWrapper2.wrappedValue == randomID)
        #expect(e2.propertyWrapper.wrappedValue == randomID)
        #expect(e3.propertyWrapper.wrappedValue == randomID)
        #expect(e4.propertyWrapper.wrappedValue == randomID)
        #expect(e5.propertyWrapper.wrappedValue == randomID)
        #expect(e6.propertyWrapper.wrappedValue == randomID)

        #expect(e2.$wrappedValue == randomID.hashValue)

        let newValue = UUID()
        e4.wrappedValue = newValue
        #expect(e4.wrappedValue == newValue)

        let newProjectedValue = Int.random(in: 0 ..< 10000)
        e5.$wrappedValue = newProjectedValue
        #expect(e5.$wrappedValue == newProjectedValue)

        #expect(e6.$wrappedValue.get() == randomID)
    }
}

private let randomID = UUID()

final class Example1: Sendable {
    @Example(randomID) var wrappedValue: UUID
    @Examples.Example(randomID) var wrappedValue2: UUID

    var propertyWrapper: Example<UUID> { _wrappedValue }
    var propertyWrapper2: Example<UUID> { _wrappedValue2 }
}

final class Example2: Sendable {
    @ExampleWithProjected(randomID) var wrappedValue: UUID

    var propertyWrapper: ExampleWithProjected<UUID> { _wrappedValue }
}

final class Example3: Sendable {
    @ExampleWithWrappedValue var wrappedValue: UUID = randomID

    var propertyWrapper: ExampleWithWrappedValue<UUID> { _wrappedValue }
}

final class Example4: Sendable {
    @ExampleSettable(randomID) var wrappedValue: UUID

    var propertyWrapper: ExampleSettable<UUID> { _wrappedValue }
}

final class Example5: Sendable {
    @ExampleWithSettableProjected(randomID) var wrappedValue: UUID

    var propertyWrapper: ExampleWithSettableProjected<UUID> { _wrappedValue }
}

final class Example6: Sendable {
    @ExampleWithGenericProjected(randomID) var wrappedValue: UUID

    var propertyWrapper: ExampleWithGenericProjected<UUID> { _wrappedValue }
}
