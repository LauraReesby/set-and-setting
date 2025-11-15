import SwiftData
import SwiftUI
import UIKit

@main
struct AfterflowApp: App {
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TherapeuticSession.self
        ])
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)

        if isUITesting, let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Self.sharedModelContainer)
        }
    }
}
