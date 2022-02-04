import NIO
import Logging
import MongoCore

public struct MongoConnectionPoolRequest: Sendable {
    public var writable: Bool

    public init(writable: Bool) {
        self.writable = writable
    }
}

public protocol MongoConnectionPool {
    func next(for request: MongoConnectionPoolRequest) async throws -> MongoConnection
    var wireVersion: WireVersion? { get async }
    var sessionManager: MongoSessionManager { get }
    var logger: Logger { get }
}

extension MongoConnection: MongoConnectionPool {
    public func next(for request: MongoConnectionPoolRequest) async throws -> MongoConnection {
        self
    }
    
    public var wireVersion: WireVersion? {
        get async { await serverHandshake?.maxWireVersion }
    }
}

public enum MongoConnectionState {
    /// Busy attempting to connect
    case connecting

    /// Connected with <connectionCount> active connections
    case connected(connectionCount: Int)

    /// No connections are open to MongoDB
    case disconnected

    /// The cluster has been shut down
    case closed
}
