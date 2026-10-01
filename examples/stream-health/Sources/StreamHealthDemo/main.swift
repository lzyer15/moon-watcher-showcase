import Foundation

let start = Date(timeIntervalSince1970: 1_000)
var sustained = TradeStreamHealth()
var timeline: [[String: Any]] = []
for second in 0...15 {
    let received = start.addingTimeInterval(Double(second))
    let quoted = received.addingTimeInterval(-10)
    let reconnect = sustained.shouldReconnect(quotedAt: quoted, receivedAt: received)
    timeline.append(["second": second, "quoteAgeSeconds": 10, "shouldReconnect": reconnect])
}
var burst = TradeStreamHealth()
var burstReconnect = false
for _ in 0..<100 {
    burstReconnect = burst.shouldReconnect(quotedAt: start.addingTimeInterval(-10), receivedAt: start) || burstReconnect
}
var quiet = TradeStreamHealth()
let quietFirst = quiet.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(60))
let quietSecond = quiet.shouldReconnect(quotedAt: start, receivedAt: start.addingTimeInterval(180))
let output: [String: Any] = ["dataMode": "synthetic", "source": "production TradeStreamHealth.swift, unchanged", "scenarios": [["name": "sustainedStaleFrames", "timeline": timeline], ["name": "sameInstantBurst", "frames": 100, "shouldReconnect": burstReconnect], ["name": "sparseQuietMarket", "shouldReconnect": quietFirst || quietSecond]]]
let data = try JSONSerialization.data(withJSONObject: output, options: [.prettyPrinted, .sortedKeys])
print(String(decoding: data, as: UTF8.self))
