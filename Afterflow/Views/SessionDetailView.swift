//  Constitutional Compliance: Privacy-First Reflections

import SwiftData
import SwiftUI

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: TherapeuticSession

    @State private var sessionDataService: SessionDataService?
    @State private var viewModel: SessionDetailViewModel?
    @FocusState private var editorFocused: Bool

    init(session: TherapeuticSession) {
        self.session = session
    }

    var body: some View {
        Form {
            self.overviewSection

            self.editableDetailsSection
            self.reflectionSection
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    self.saveReflection()
                    self.dismiss()
                }
                .disabled(!(self.viewModel?.hasChanges ?? false) || (self.viewModel?.isSaving ?? true))
            }
        }
        .onAppear {
            self.prepareViewModelIfNeeded()
        }
        .onChange(of: self.session.reflections) { _, newValue in
            self.viewModel?.reflectionText = newValue
        }
    }

    private var overviewSection: some View {
        Section("Session Overview") {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.session.displayTitle)
                    .font(.headline)
                Text(self.session.intention)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Treatment", systemImage: "leaf")
                    .foregroundColor(.secondary)
                Spacer()
                Text(self.session.treatmentType.displayName)
                    .bold()
            }

            HStack {
                Label("Mood Shift", systemImage: "smiley")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(self.session.moodBefore) → \(self.session.moodAfter)")
                    .bold()
            }
        }
    }

    private var editableDetailsSection: some View {
        Section("Details") {
            TextField("Dosage", text: Binding(
                get: { self.viewModel?.dosage ?? "" },
                set: { self.viewModel?.dosage = $0 }
            ))
            .textContentType(.none)
            .autocorrectionDisabled()

            Picker("Administration", selection: Binding(
                get: { self.viewModel?.administration ?? .oral },
                set: { self.viewModel?.administration = $0 }
            )) {
                ForEach(AdministrationMethod.allCases, id: \.self) { method in
                    Text(method.displayName).tag(method)
                }
            }

            TextField("Environment notes", text: Binding(
                get: { self.viewModel?.environmentNotes ?? "" },
                set: { self.viewModel?.environmentNotes = $0 }
            ), axis: .vertical)
                .lineLimit(1 ... 3)

            TextField("Music notes", text: Binding(
                get: { self.viewModel?.musicNotes ?? "" },
                set: { self.viewModel?.musicNotes = $0 }
            ), axis: .vertical)
                .lineLimit(1 ... 3)

            MoodRatingView(value: Binding(
                get: { self.viewModel?.moodBefore ?? 5 },
                set: { self.viewModel?.moodBefore = $0 }
            ), title: "Before Session", accessibilityIdentifier: "detailMoodBefore")

            MoodRatingView(value: Binding(
                get: { self.viewModel?.moodAfter ?? 5 },
                set: { self.viewModel?.moodAfter = $0 }
            ), title: "After Session", accessibilityIdentifier: "detailMoodAfter")
        }
    }

    private var reflectionSection: some View {
        Section("Reflections") {
            ZStack(alignment: .topLeading) {
                TextEditor(text: self.reflectionBinding)
                    .frame(minHeight: 160)
                    .padding(.top, 8)
                    .accessibilityIdentifier("reflectionEditor")
                    .focused(self.$editorFocused)

                if self.reflectionBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Share insights, integration notes, or anything your future self may need.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.1))
            )

            if let errorMessage = self.viewModel?.errorMessage {
                ValidationErrorView(message: errorMessage)
                    .padding(.top, 4)
                    .accessibilityIdentifier("reflectionErrorBanner")
            }

            if self.viewModel?.showSuccessMessage == true {
                Label("Reflection saved", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 4)
                    .accessibilityIdentifier("reflectionSuccessBanner")
            }
        }
    }

    private var reflectionBinding: Binding<String> {
        Binding<String>(
            get: { self.viewModel?.reflectionText ?? "" },
            set: { newValue in self.viewModel?.reflectionText = newValue }
        )
    }

    private func saveReflection() {
        guard let viewModel = self.viewModel else { return }
        viewModel.saveReflection()

        if viewModel.showSuccessMessage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.dismissSuccessMessage()
            }
        }
    }

    private func prepareViewModelIfNeeded() {
        guard self.viewModel == nil else { return }
        let service = self.ensureDataService()
        self.viewModel = SessionDetailViewModel(session: self.session, persistence: service)
    }

    @discardableResult private func ensureDataService() -> SessionDataService {
        if let service = self.sessionDataService {
            return service
        }

        let service = SessionDataService(modelContext: self.modelContext)
        self.sessionDataService = service
        return service
    }
}

#Preview {
    let previewSession = TherapeuticSession(
        treatmentType: .psilocybin,
        intention: "Integrate recent therapy insights",
        moodBefore: 4,
        moodAfter: 8,
        reflections: "Felt a deeper sense of clarity around recurring patterns."
    )
    return SessionDetailView(session: previewSession)
        .modelContainer(for: TherapeuticSession.self, inMemory: true)
}
