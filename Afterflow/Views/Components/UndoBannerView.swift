import SwiftUI

struct UndoBannerView: View {
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .accessibilityIdentifier("undoBannerMessage")

            Spacer()

            Button(actionTitle) {
                self.action()
            }
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.primary.opacity(0.1)))
            .accessibilityIdentifier("undoBannerAction")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(radius: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message). \(actionTitle)")
    }
}

#if DEBUG
    struct UndoBannerView_Previews: PreviewProvider {
        static var previews: some View {
            UndoBannerView(message: "Deleted Psilocybin • Nov 14", actionTitle: "Undo") {}
                .padding()
        }
    }
#endif
