import Combine
// Comment the next line out to see compiler error
import DemoMacro
import DemoPropertyWrapper

final class Client: Sendable {
    @Locked var lockedValue: String = ""
}
