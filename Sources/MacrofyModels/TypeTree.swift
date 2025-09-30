//
//  TypeTree.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/26/25.
//

import SwiftSyntax

public struct TypeTree {
    public init(type: String, children: [TypeTree] = []) {
        self.type = type
        self.children = children
    }

    public let type: String
    public let children: [TypeTree]

    public func adding(children: [TypeTree]) -> Self {
        TypeTree(type: type, children: children)
    }
}

public extension TypeTree {
    init(_ identifierTypeSyntax: IdentifierTypeSyntax) {
        let children: [TypeTree]
        if let genericArgumentClause = identifierTypeSyntax.genericArgumentClause {
            children = genericArgumentClause.arguments.compactMap { $0.argument.as(IdentifierTypeSyntax.self) }.map(Self.init)
        } else {
            children = []
        }
        self.init(type: identifierTypeSyntax.name.text, children: children)
    }
}

extension TypeTree: Sequence {
    public typealias Element = TypeTree

    public func makeIterator() -> AnyIterator<Element> {
        let iterator = ([self] + children).makeIterator()
        return AnyIterator(iterator)
    }
}

extension TypeTree {
    public var typeSyntax: TypeSyntax {
        TypeSyntax(IdentifierTypeSyntax(name: .identifier(type), genericArgumentClause: genericArgumentClause))
    }

    private var genericArgumentClause: GenericArgumentClauseSyntax? {
        guard !children.isEmpty else {
            return nil
        }
        let childrenCount = children.count
        return GenericArgumentClauseSyntax(arguments: GenericArgumentListSyntax(children.enumerated().map {
            GenericArgumentSyntax(argument: .type(TypeSyntax(IdentifierTypeSyntax(name: .identifier($1.type)))),
                                  trailingComma: $0 < childrenCount - 1 ? .commaToken() : nil)
        }))
    }
}

extension TypeTree: CustomStringConvertible {
    public var description: String {
        typeSyntax.description
    }
}

public extension TypeTree {
    func replacing(type: String, with newType: String) -> Self {
        let typeTree: Self
        if self.type == type {
            typeTree = TypeTree(type: newType)
        } else {
            typeTree = self
        }
        let replacedChildren = children.map { $0.replacing(type: type, with: newType) }
        return typeTree.adding(children: replacedChildren)
    }
}

extension TypeTree: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.type == rhs.type else {
            return false
        }
        guard lhs.children.count == rhs.children.count else {
            return false
        }
        return zip(lhs.children, rhs.children).allSatisfy { $0 == $1 }
    }
}
