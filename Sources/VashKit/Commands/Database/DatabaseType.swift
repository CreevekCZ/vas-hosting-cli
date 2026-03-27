import ArgumentParser

public enum DatabaseType: String, CaseIterable, ExpressibleByArgument, Sendable {
    case mysql
    case postgresql
}
