import Combine
import Foundation
import os.log

@MainActor
final class NotificationPerformanceMonitor: ObservableObject {
    enum PerformanceTarget {
        static let deepLinkLatency: TimeInterval = 1.0
        static let reflectionSave: TimeInterval = 0.3
        static let queueReplay: TimeInterval = 1.0
    }

    struct PerformanceMetrics {
        var deepLinkLatency: TimeInterval?
        var reflectionSaveTime: TimeInterval?
        var queueReplayTime: TimeInterval?

        var allTargetsMet: Bool {
            guard let deepLink = deepLinkLatency,
                  let reflection = reflectionSaveTime,
                  let replay = queueReplayTime
            else { return false }

            return deepLink <= PerformanceTarget.deepLinkLatency &&
                reflection <= PerformanceTarget.reflectionSave &&
                replay <= PerformanceTarget.queueReplay
        }
    }

    @Published private(set) var latestMetrics = PerformanceMetrics()

    private let logger = Logger(subsystem: "com.afterflow.app", category: "NotificationPerformance")

    func measureDeepLinkProcessing<T>(_ operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer { self.record(
            \.deepLinkLatency,
            name: "Deep Link Processing",
            startTime: startTime,
            target: PerformanceTarget.deepLinkLatency
        ) }
        return try await operation()
    }

    func measureReflectionSave<T>(_ operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer { self.record(
            \.reflectionSaveTime,
            name: "Reflection Save",
            startTime: startTime,
            target: PerformanceTarget.reflectionSave
        ) }
        return try await operation()
    }

    func measureQueueReplay<T>(_ operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer { self.record(
            \.queueReplayTime,
            name: "Queue Replay",
            startTime: startTime,
            target: PerformanceTarget.queueReplay
        ) }
        return try await operation()
    }

    private func record(
        _ keyPath: WritableKeyPath<PerformanceMetrics, TimeInterval?>,
        name: String,
        startTime: CFAbsoluteTime,
        target: TimeInterval
    ) {
        let latency = CFAbsoluteTimeGetCurrent() - startTime
        self.latestMetrics[keyPath: keyPath] = latency
        self.logPerformance(name, latency: latency, target: target)
    }

    private func logPerformance(_ operation: String, latency: TimeInterval, target: TimeInterval) {
        let latencyMs = latency * 1000
        let targetMs = target * 1000
        let meetsTarget = latency <= target

        if meetsTarget {
            self.logger
                .info(
                    "✅ \(operation): \(latencyMs, format: .fixed(precision: 1))ms (target: \(targetMs, format: .fixed(precision: 0))ms)"
                )
        } else {
            self.logger
                .warning(
                    "⚠️ \(operation): \(latencyMs, format: .fixed(precision: 1))ms exceeded target \(targetMs, format: .fixed(precision: 0))ms"
                )
        }
    }

    func resetMetrics() {
        self.latestMetrics = PerformanceMetrics()
    }
}
