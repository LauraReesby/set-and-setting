import Foundation
import SwiftUI

/// A simple validation result representation for UI display
struct ValidationDisplay {
    let isValid: Bool
    let message: String?

    init(isValid: Bool, message: String? = nil) {
        self.isValid = isValid
        self.message = message
    }
}

/// A reusable SwiftUI view for displaying therapeutic validation errors
/// with accessibility support and calming design
struct ValidationErrorView: View {
    let message: String?

    var body: some View {
        if let message {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.orange)
                    .font(.caption)
                    .accessibilityHidden(true) // Screen reader will read the text

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("validation_suggestion_text")
                    .accessibilityLabel("Validation suggestion: \(message)")

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.orange.opacity(0.1))
                    .stroke(.orange.opacity(0.3), lineWidth: 1)
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.2), value: message)
        }
    }
}

/// A modifier that adds inline validation error display to form fields
struct InlineValidationModifier: ViewModifier {
    let validationResult: ValidationDisplay?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .background(
                    // Use background instead of overlay to prevent frame dimension issues
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            self.validationResult?.isValid == false ? .orange.opacity(0.5) : .clear,
                            lineWidth: 1
                        )
                        .allowsHitTesting(false) // Prevent interaction with the stroke
                )

            // Always reserve space for validation message to prevent layout jumping
            Group {
                if let result = validationResult, !result.isValid, let message = result.message {
                    ValidationErrorView(message: message)
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                } else {
                    // Reserve minimal space when no error to prevent layout shifts
                    Color.clear
                        .frame(height: 0)
                }
            }
        }
    }
}

extension View {
    /// Adds inline validation error display to any view
    /// - Parameter validationResult: The validation result to display
    /// - Returns: A view with inline error display capability
    func inlineValidation(_ validationResult: ValidationDisplay?) -> some View {
        self.modifier(InlineValidationModifier(validationResult: validationResult))
    }

    /// Convenience method for any validation result type with isValid and message properties
    /// This uses reflection to extract the properties from any compatible type
    func inlineValidation(_ validationResult: (some Any)?) -> some View {
        let display: ValidationDisplay?
        if let result = validationResult {
            let mirror = Mirror(reflecting: result)
            var isValid = true
            var message: String?

            // Extract isValid and message using reflection
            for child in mirror.children {
                if child.label == "isValid" {
                    isValid = (child.value as? Bool) ?? true
                }
                if child.label == "message" {
                    message = child.value as? String
                }
            }
            display = ValidationDisplay(isValid: isValid, message: message)
        } else {
            display = nil
        }

        return self.modifier(InlineValidationModifier(validationResult: display))
    }
}

#if DEBUG
    struct ValidationErrorView_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 20) {
                // Example with error message
                TextField("Intention", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .inlineValidation(ValidationDisplay(
                        isValid: false,
                        message: "Please share what you hope to explore in this session"
                    ))

                // Example with no error
                TextField("Dosage", text: .constant("3.5g"))
                    .textFieldStyle(.roundedBorder)
                    .inlineValidation(ValidationDisplay(isValid: true, message: nil))

                // Direct error view
                ValidationErrorView(message: "Please keep dosage brief for easier tracking")
            }
            .padding()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            VStack(spacing: 20) {
                TextField("Intention", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .inlineValidation(ValidationDisplay(
                        isValid: false,
                        message: "Please share what you hope to explore in this session"
                    ))
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
#endif
