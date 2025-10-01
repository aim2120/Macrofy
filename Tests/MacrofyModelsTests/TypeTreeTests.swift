//
//  TypeTreeTests.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/26/25.
//

import MacrofyModels
import SwiftSyntax
import SwiftSyntaxMacros
import Testing

@Suite
struct TypeTreeTests {
    @Test
    func createsTreeForType_noGenerics() {
        let declSyntax: DeclSyntax = "var value: Value1"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1"))
    }

    @Test
    func createsTreeForType_nestedOnce_single() {
        let declSyntax: DeclSyntax = "var value: Value1<Value2>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value2"),
        ]))
    }

    @Test
    func createsTreeForType_nestedOnce_multiple() {
        let declSyntax: DeclSyntax = "var value: Value1<Value21, Value22, Value23>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value21"),
            TypeTree(type: "Value22"),
            TypeTree(type: "Value23"),
        ]))
    }

    @Test
    func createsTreeForType_nestedTwice_single() {
        let declSyntax: DeclSyntax = "var value: Value1<Value2<Value3>>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value2", children: [
                TypeTree(type: "Value3"),
            ]),
        ]))
    }

    @Test
    func createsTreeForType_nestedTwice_multiple() {
        let declSyntax: DeclSyntax = "var value: Value1<Value21<Value31, Value32, Value33>, Value22<Value31, Value32>, Value23>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value21", children: [
                TypeTree(type: "Value31"),
                TypeTree(type: "Value32"),
                TypeTree(type: "Value33"),
            ]),
            TypeTree(type: "Value22", children: [
                TypeTree(type: "Value31"),
                TypeTree(type: "Value32"),
            ]),
            TypeTree(type: "Value23"),
        ]))
    }

    @Test
    func createsTreeForType_nestedThrice_single() {
        let declSyntax: DeclSyntax = "var value: Value1<Value2<Value3<Value4>>>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value2", children: [
                TypeTree(type: "Value3", children: [
                    TypeTree(type: "Value4"),
                ]),
            ]),
        ]))
    }

    @Test
    func createsTreeForType_nestedThrice_multiple() {
        let declSyntax: DeclSyntax = "var value: Value1<Value21<Value31<Value41, Value42>, Value32, Value33>, Value22<Value31, Value32<Value41>>, Value23>"
        let identifierType: IdentifierTypeSyntax = declSyntax.as(VariableDeclSyntax.self)!.bindings.first!.typeAnnotation!.type.as(IdentifierTypeSyntax.self)!
        let typeTree = TypeTree(identifierType)
        #expect(typeTree == TypeTree(type: "Value1", children: [
            TypeTree(type: "Value21", children: [
                TypeTree(type: "Value31", children: [
                    TypeTree(type: "Value41"),
                    TypeTree(type: "Value42"),
                ]),
                TypeTree(type: "Value32"),
                TypeTree(type: "Value33"),
            ]),
            TypeTree(type: "Value22", children: [
                TypeTree(type: "Value31"),
                TypeTree(type: "Value32", children: [
                    TypeTree(type: "Value41"),
                ]),
            ]),
            TypeTree(type: "Value23"),
        ]))
    }
}
