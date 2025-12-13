import SwiftUI

struct TreatmentAvatar: View {
    let type: PsychedelicTreatmentType

    init(type: PsychedelicTreatmentType) {
        self.type = type
    }

    var body: some View {
        ZStack {
            // Base color with slight translucency
            Circle()
                .fill(self.type.accentColor.opacity(0.85))

            // Gentle top-to-bottom white wash for depth
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.softLight)

            // Initials slightly softened
            Text(self.type.initials)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                .accessibilityHidden(true)

            // Glassy sheen highlight
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)
                .opacity(0.6)
        }
        .overlay(
            // A very subtle inner highlight ring
            Circle()
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
                .blendMode(.overlay)
        )
        .overlay(
            // Soft outer edge to help against light/dark backgrounds
            Circle()
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
        )
        .frame(width: 36, height: 36)
        .compositingGroup()
        .accessibilityIdentifier("treatmentAvatar")
    }
}
