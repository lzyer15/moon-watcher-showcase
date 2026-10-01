import Foundation

// Small assertion adapter so the original scenarios run without XCTest/Xcode.
class XCTestCase {}
var checks = 0
func XCTAssertFalse(_ value: Bool) { checks += 1; precondition(!value, "Expected false") }
func XCTAssertTrue(_ value: Bool) { checks += 1; precondition(value, "Expected true") }


final class TradeStreamHealthTests: XCTestCase {
    let start = Date(timeIntervalSince1970: 1_000)

    func testSustainedStaleFramesRecoverButOneBurstDoesNot() {
        var health = TradeStreamHealth()
        for second in 0..<15 {
            XCTAssertFalse(health.shouldReconnect(quotedAt: start.addingTimeInterval(-10),
                                                  receivedAt: start.addingTimeInterval(Double(second))))
        }
        XCTAssertTrue(health.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(15)))
        var burst = TradeStreamHealth()
        for _ in 0..<100 { XCTAssertFalse(burst.shouldReconnect(quotedAt: start.addingTimeInterval(-10), receivedAt: start)) }
    }

    func testFreshMarketFramesResetAndSparseQuietMarketDoesNotReconnect() {
        var health = TradeStreamHealth()
        for second in 0..<14 {
            _ = health.shouldReconnect(quotedAt: start.addingTimeInterval(-10), receivedAt: start.addingTimeInterval(Double(second)))
        }
        XCTAssertFalse(health.shouldReconnect(quotedAt: start.addingTimeInterval(14), receivedAt: start.addingTimeInterval(14)))
        XCTAssertFalse(health.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(20)))
        var quiet = TradeStreamHealth()
        XCTAssertFalse(quiet.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(60)))
        XCTAssertFalse(quiet.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(180)))
    }
}

let suite = TradeStreamHealthTests()
suite.testSustainedStaleFramesRecoverButOneBurstDoesNot()
suite.testFreshMarketFramesResetAndSparseQuietMarketDoesNotReconnect()
print("PASS: 2 production scenarios, \(checks) assertions")
