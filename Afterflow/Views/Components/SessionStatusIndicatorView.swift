import SwiftUI

struct SessionStatusIndicatorView: View {
    let status: SessionLifecycleStatus
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .imageScale(.large)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundTint)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(detail)
    }

    private var title: String {
        switch status {
        case .draft:
            return "Draft • Capture your intention"
        case .needsReflection:
            return "Needs Reflection • Return later to reflect"
        case .complete:
            return "Complete • Reflections saved"
        }
    }

    private var detail: String {
        switch status {
        case .draft:
            return "Complete the required fields below to save this entry and set an optional reminder."
        case .needsReflection:
            return "This session is waiting for reflections. You'll see it highlighted in your history until you finish."
        case .complete:
            return "This session is complete. You can still update reflections any time."
        }
    }

    private var iconName: String {
        switch status {
        case .draft: return "square.fill"
        case .needsReflection: return "square.lefthalf.fill"
        case .complete: return "checkmark.square.fill"
        }
    }

    private var iconColor: Color {
        switch status {
        case .draft: return .blue
        case .needsReflection: return .orange
        case .complete: return .green
        }
    }

    private var backgroundTint: Color {
        switch status {
        case .draft: return Color.blue.opacity(0.15)
        case .needsReflection: return Color.orange.opacity(0.15)
        case .complete: return Color.green.opacity(0.15)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SessionStatusIndicatorView(status: .draft)
        SessionStatusIndicatorView(status: .needsReflection)
        SessionStatusIndicatorView(status: .complete)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
