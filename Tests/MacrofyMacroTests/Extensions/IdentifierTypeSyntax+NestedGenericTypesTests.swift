//
//  IdentifierTypeSyntax+NestedGenericTypesTests.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/26/25.
//

@testable import MacrofyMacro
import SwiftSyntax
import Testing

@Suite
struct IdentifierTypeSyntaxNestedGenericTypesTests {
    @Test
    func returnsEmptyArrayForNoGenericClause() {
        #expect(IdentifierTypeSyntax(name: "TestType").nestedGenericTypes.isEmpty)
    }

    @Test
    func returnsGenericType() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
        ])
    }

    @Test
    func returnsGenericTypes() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1"))
            GenericArgumentSyntax(argument: .type("Generic2"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
            "Generic2",
        ])
    }

    @Test
    func returnsGenericTypes_nestedOnce() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1<Generic11>"))
            GenericArgumentSyntax(argument: .type("Generic2<Generic21>"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
            "Generic11",
            "Generic2",
            "Generic21",
        ])
    }

    @Test
    func returnsGenericTypes_nestedTwice() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1<Generic11<Generic111>>"))
            GenericArgumentSyntax(argument: .type("Generic2<Generic21<Generic211>>"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
            "Generic11",
            "Generic111",
            "Generic2",
            "Generic21",
            "Generic211",
        ])
    }

    @Test
    func returnsGenericTypes_nestedThrice() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1<Generic11<Generic111<Generic1111>>>"))
            GenericArgumentSyntax(argument: .type("Generic2<Generic21<Generic211<Generic2111>>>"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
            "Generic11",
            "Generic111",
            "Generic1111",
            "Generic2",
            "Generic21",
            "Generic211",
            "Generic2111",
        ])
    }

    @Test
    func returnsGenericTypes_multipleGenericsPerLevel() {
        let identifierTypeSyntax = IdentifierTypeSyntax(name: "TestType", genericArgumentClause: GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(itemsBuilder: {
            GenericArgumentSyntax(argument: .type("Generic1<Generic11<Generic111<Generic1111>>, Generic12<Generic121>>"))
            GenericArgumentSyntax(argument: .type("Generic2<Generic21<Generic211<Generic2111>>, Generic22<Generic221>>"))
        })))
        #expect(identifierTypeSyntax.nestedGenericTypes.map(\.description) == [
            "Generic1",
            "Generic11",
            "Generic111",
            "Generic1111",
            "Generic12",
            "Generic121",
            "Generic2",
            "Generic21",
            "Generic211",
            "Generic2111",
            "Generic22",
            "Generic221",
        ])
    }
}
