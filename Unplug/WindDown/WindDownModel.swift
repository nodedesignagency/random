import SwiftUI
import Observation

struct SleepyApp: Identifiable, Hashable {
    let id: Int
    let name: String
    /// Shown as a buzzing badge on the illustration until the app is tucked in.
    let unread: Int
}

/// Drives the "putting your apps to bed" sequence.
///
/// For now this simulates the work with timed steps. When the Screen Time integration lands,
/// replace the sleeps in `run()` with the real FamilyControls / ManagedSettings calls and keep
/// updating `tuckedCount` and `progress` the same way; the sheet animates from those alone.
@MainActor
@Observable
final class WindDownModel {
    let apps: [SleepyApp] = [
        SleepyApp(id: 0, name: "Instagram", unread: 12),
        SleepyApp(id: 1, name: "TikTok", unread: 8),
        SleepyApp(id: 2, name: "X", unread: 5),
    ]
    let wakeTime = "7:00 AM"
    let wakeTimeShort = "7 AM"

    private(set) var tuckedCount = 0
    private(set) var progress: Double = 0

    var isComplete: Bool { tuckedCount >= apps.count }

    var currentApp: SleepyApp? {
        isComplete ? nil : apps[tuckedCount]
    }

    func run() async {
        tuckedCount = 0
        progress = 0

        // Let the sheet's entrance settle before anything starts moving.
        guard await pause(milliseconds: 900) else { return }

        for index in apps.indices {
            // Creep towards the next checkpoint so the bar never looks stuck...
            withAnimation(.easeInOut(duration: 1.1)) {
                progress = (Double(index) + 0.85) / Double(apps.count)
            }
            guard await pause(milliseconds: 1250) else { return }

            // ...then land on it as the app falls asleep.
            withAnimation(.spring(duration: 0.55, bounce: 0.3)) {
                tuckedCount = index + 1
                progress = Double(index + 1) / Double(apps.count)
            }
            guard await pause(milliseconds: 450) else { return }
        }
    }

    /// Returns `false` if the task was cancelled (the sheet was dismissed).
    private func pause(milliseconds: Int) async -> Bool {
        do {
            try await Task.sleep(for: .milliseconds(milliseconds))
            return true
        } catch {
            return false
        }
    }
}
