import SwiftUI
import SwiftData
import UIKit

@main
struct AfterflowApp: App {
    private static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TherapeuticSession.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
