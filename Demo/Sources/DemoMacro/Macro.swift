@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro Locked(
    _ arguments: Any...
) = #externalMacro(module: "DemoMacroInternal", type: "LockedMacro")
