//  Constitutional Compliance: Privacy-First Reflections

import SwiftData
import SwiftUI

struct SessionDetailView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let session: TherapeuticSession

    @State private var showingEdit = false

    var body: some View {
        List {
            self.summarySection

            Section("When") {
                SessionDetailRow(title: "Date & Time", value: self.dateFormatter.string(from: self.session.sessionDate))
            }

            Section("Treatment") {
                SessionDetailRow(title: "Type", value: self.session.treatmentType.displayName)
                SessionDetailRow(title: "Administration", value: self.session.administration.displayName)
            }

            Section("Intention") {
                Text(self.session.intention.isEmpty ? "No intention captured." : self.session.intention)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section("Mood") {
                self.moodRow(title: "Before", value: self.session.moodBefore)
                if self.hasAfterMood {
                    self.moodRow(title: "After", value: self.session.moodAfter)
                } else {
                    SessionDetailRow(title: "After", value: "Not added yet")
                }
            }

            Section("Music") {
                if self.session.hasMusicLink {
                    MusicLinkSummaryCard(session: self.session)
                    if let url = session.preferredOpenURL {
                        Button {
                            self.openURL(url)
                        } label: {
                            Label("Open link", systemImage: "arrow.up.right.square")
                                .font(.subheadline)
                        }
                    }
                } else {
                    Text("No playlist attached")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Reflection") {
                if self.session.reflections.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("You haven’t added reflections yet.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(self.session.reflections)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Edit") {
                    self.showingEdit = true
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: self.$showingEdit) {
            NavigationStack {
                SessionFormView(session: self.session)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(16)
            .toolbarBackground(.visible, for: .automatic)
        }
    }

    private var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(self.session.treatmentType.displayName)
                            .font(.headline)
                        Text(self.dateFormatter.string(from: self.session.sessionDate))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if self.session.hasMusicLink {
                        Image(systemName: "music.note.list")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Music attached")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Intention")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let trimmed = self.session.intention.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(trimmed.isEmpty ? "No intention captured." : trimmed)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 8) {
                    StatusPill(status: self.session.status)
                    if self.hasAfterMood {
                        MoodDeltaPill(before: self.session.moodBefore, after: self.session.moodAfter)
                    } else {
                        MoodBeforePill(value: self.session.moodBefore)
                    }
                }
                .padding(.top, 4)

                if self.session.status == .needsReflection,
                   let reminderLabel = self.session.reminderDisplayText
                {
                    ReminderPill(text: reminderLabel)
                        .accessibilityIdentifier("detailReminderLabel")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 8, leading: 0, bottom: 0, trailing: 0))
    }

    private func moodRow(title: String, value: Int, placeholder: String = "") -> some View {
        let descriptor = MoodRatingScale.descriptor(for: value)
        let emoji = MoodRatingScale.emoji(for: value)
        return AnyView(SessionDetailRow(title: title, value: "\(value) (\(descriptor)) \(emoji)"))
    }

    private var hasAfterMood: Bool {
        let reflectionSet = !self.session.reflections.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return reflectionSet || self.session.moodAfter != 5
    }

    private var moodSummaryText: String {
        let beforeDescriptor = MoodRatingScale.descriptor(for: self.session.moodBefore)
        let afterDescriptor = MoodRatingScale.descriptor(for: self.session.moodAfter)
        let before = "\(session.moodBefore) (\(beforeDescriptor))"

        if self.hasAfterMood {
            let after = "\(session.moodAfter) (\(afterDescriptor))"
            return "Mood • \(before) → \(after)"
        } else {
            return "Mood • \(before) → —"
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

private struct SessionDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(self.title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(self.value)
                .multilineTextAlignment(.trailing)
        }
        .font(.body)
    }
}

private extension SessionLifecycleStatus {
    var symbolName: String {
        switch self {
        case .draft: "square.dashed"
        case .needsReflection: "hourglass"
        case .complete: "checkmark.seal.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .draft: .blue
        case .needsReflection: .orange
        case .complete: .green
        }
    }
}

private struct StatusPill: View {
    let status: SessionLifecycleStatus

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: status.symbolName)
            Text(self.labelText)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(status.accentColor.opacity(0.15))
        .foregroundStyle(status.accentColor)
        .clipShape(Capsule())
    }

    private var labelText: String {
        switch self.status {
        case .needsReflection: "Reflect"
        default: self.status.displayName
        }
    }
}

private struct MoodDeltaPill: View {
    let before: Int
    let after: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: self.iconName)
            Text("Mood \(before) → \(after)")
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(self.tintColor.opacity(0.15))
        .foregroundStyle(self.tintColor)
        .clipShape(Capsule())
    }

    private var iconName: String {
        after >= before ? "arrow.up.right" : "arrow.down.right"
    }

    private var tintColor: Color {
        after >= before ? .blue : .purple
    }
}

private struct MoodBeforePill: View {
    let value: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "face.smiling")
            Text("Mood \(value)")
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.teal.opacity(0.15))
        .foregroundStyle(Color.teal)
        .clipShape(Capsule())
    }
}

private struct ReminderPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "bell")
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.pink.opacity(0.18))
        .foregroundStyle(Color.pink)
        .clipShape(Capsule())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TherapeuticSession.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = SessionStore(modelContext: container.mainContext, owningContainer: container)
    let session = TherapeuticSession(intention: "Feel more open with my partner", moodBefore: 4, moodAfter: 7)
    try! store.create(session)
    return NavigationStack {
        SessionDetailView(session: session)
    }
    .modelContainer(container)
    .environment(store)
}
