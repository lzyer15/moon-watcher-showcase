import Foundation

/// Transport connected does not mean quotes are current. Only sustained incoming stale
/// frames trigger recovery; a quiet market or one illiquid symbol is not a failure.
struct TradeStreamHealth {
    private var staleSince: Date?
    private var staleCount = 0

    mutating func shouldReconnect(quotedAt: Date, receivedAt: Date) -> Bool {
        let age = receivedAt.timeIntervalSince(quotedAt)
        if (0...5).contains(age) {
            staleSince = nil; staleCount = 0
            return false
        }
        if staleSince == nil { staleSince = receivedAt }
        staleCount += 1
        return staleCount >= 10 && receivedAt.timeIntervalSince(staleSince!) >= 15
    }
}
