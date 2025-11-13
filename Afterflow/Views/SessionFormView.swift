//  Constitutional Compliance: Privacy-First, SwiftUI Native, Therapeutic Value-First

//  Constitutional Compliance: Privacy-First, SwiftUI Native, Therapeutic Value-First

import SwiftUI
import SwiftData

struct SessionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    @State private var sessionDate = Date()
    @State private var selectedTreatmentType = PsychedelicTreatmentType.psilocybin
    @State private var dosage = ""
    @State private var selectedAdministration = AdministrationMethod.oral
    @State private var intention = ""
    
    // MARK: - Focus Management
    @FocusState private var focusedField: FormField?
    
    enum FormField: CaseIterable {
        case dosage
        case intention
    }
    
    // MARK: - Validation
    @State private var validator = FormValidation()
    @State private var intentionValidation: ValidationResult?
    @State private var dateValidation: ValidationResult?
    @State private var dosageValidation: ValidationResult?
    @State private var validationTask: Task<Void, Never>?
    
    // MARK: - UI State
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDateNormalizationHint = false
    @State private var dateNormalizationMessage = ""
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        let formData = SessionFormData(
            sessionDate: sessionDate,
            treatmentType: selectedTreatmentType,
            dosage: dosage,
            administration: selectedAdministration,
            intention: intention
        )
        let formValidation = validator.validateForm(formData)
        return formValidation.isValid
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "Session Date",
                        selection: $sessionDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .onChange(of: sessionDate) { oldValue, newValue in
                        handleDateChange(from: oldValue, to: newValue)
                    }
                    .inlineValidation(dateValidation)
                    
                    // Show date normalization hint if needed - use more stable layout
                    if showDateNormalizationHint && !dateNormalizationMessage.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                
                                Text(dateNormalizationMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: showDateNormalizationHint)
                    }
                } header: {
                    Text("When")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Section {
                    Picker("Treatment Type", selection: $selectedTreatmentType) {
                        ForEach(PsychedelicTreatmentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Dosage (e.g., 3.5g, 100μg)", text: $dosage)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .dosage)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .intention
                        }
                        .onChange(of: dosage) { oldValue, newValue in
                            debounceValidation()
                        }
                        .inlineValidation(dosageValidation)
                        .accessibilityIdentifier("dosageField")
                        .accessibilityLabel("Dosage")
                        .accessibilityHint("Enter the amount taken, for example 3.5g or 100μg")
                    
                    Picker("Administration", selection: $selectedAdministration) {
                        ForEach(AdministrationMethod.allCases, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Treatment")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Section {
                    TextField(
                        "What do you hope to explore or heal?",
                        text: $intention,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .textContentType(.none)
                    .focused($focusedField, equals: .intention)
                    .submitLabel(.done)
                    .onSubmit {
                        if isFormValid {
                            saveSession()
                        }
                    }
                    .onChange(of: intention) { oldValue, newValue in
                        debounceValidation()
                    }
                    .inlineValidation(intentionValidation)
                    .accessibilityIdentifier("intentionField")
                    .accessibilityLabel("Intention")
                    .accessibilityHint("Describe what you hope to explore or heal during this session")
                } header: {
                    Text("Intention")
                        .font(.headline)
                        .foregroundColor(.primary)
                } footer: {
                    Text("Take a moment to reflect on your hopes for this session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissKeyboard()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSession()
                    }
                    .disabled(isLoading || !isFormValid)
                }
                
                // Keyboard toolbar for better UX
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
            .disabled(isLoading)
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            setupInitialState()
            
            // Auto-focus first text field for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if dosage.isEmpty {
                    focusedField = .dosage
                } else if intention.isEmpty {
                    focusedField = .intention
                }
            }
        }
    }
    
    // MARK: - Validation Methods
    
    private func handleDateChange(from oldDate: Date, to newDate: Date) {
        // Normalize the date
        let normalizedDate = validator.normalizeSessionDate(newDate)
        
        // Check if normalization changed the date significantly
        if let message = validator.getDateNormalizationMessage(originalDate: newDate, normalizedDate: normalizedDate) {
            // Update the date to normalized version if significantly different
            if abs(normalizedDate.timeIntervalSince(newDate)) > 60 {
                sessionDate = normalizedDate
            }
            
            // Show hint message
            dateNormalizationMessage = message
            showDateNormalizationHint = true
            
            // Hide hint after 4 seconds
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(4))
                showDateNormalizationHint = false
            }
        }
        
        debounceValidation()
    }
    
    private func debounceValidation() {
        // Cancel previous validation task
        validationTask?.cancel()
        
        // Start new validation task with 300ms delay
        validationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            
            guard !Task.isCancelled else { return }
            
            performValidation()
        }
    }
    
    @MainActor
    private func performValidation() {
        // Validate individual fields with enhanced date validation
        intentionValidation = validator.validateIntention(intention)
        
        // Use normalized date for validation
        let normalizedDate = validator.normalizeSessionDate(sessionDate)
        dateValidation = validator.validateSessionDate(normalizedDate)
        
        dosageValidation = validator.validateDosage(dosage)
    }
    
    // MARK: - Lifecycle
    
    private func setupInitialState() {
        // Perform initial validation
        Task { @MainActor in
            performValidation()
        }
    }
    
    // MARK: - Actions
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func saveSession() {
        // Normalize date before final validation and saving
        let normalizedDate = validator.normalizeSessionDate(sessionDate)
        
        // Final validation before saving
        let formData = SessionFormData(
            sessionDate: normalizedDate,
            treatmentType: selectedTreatmentType,
            dosage: dosage,
            administration: selectedAdministration,
            intention: intention
        )
        
        let formValidation = validator.validateForm(formData)
        
        guard formValidation.isValid else {
            showError(message: formValidation.errors.first ?? "Please check your inputs")
            return
        }
        
        isLoading = true
        
        let newSession = TherapeuticSession(
            sessionDate: normalizedDate,
            treatmentType: selectedTreatmentType,
            dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines),
            administration: selectedAdministration,
            intention: intention.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        do {
            modelContext.insert(newSession)
            try modelContext.save()
            
            // Success - dismiss the form
            dismiss()
        } catch {
            isLoading = false
            showError(message: "Unable to save session: \(error.localizedDescription)")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    SessionFormView()
        .modelContainer(for: TherapeuticSession.self, inMemory: true)
}