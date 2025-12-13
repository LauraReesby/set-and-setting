import SwiftUI

extension PsychedelicTreatmentType {
    var accentColor: Color {
        switch self {
        case .ketamine: Color.cyan
        case .psilocybin: Color.purple
        case .lsd: Color.indigo
        case .mdma: Color.orange
        case .dmt: Color.teal
        case .ayahuasca: Color.brown
        case .mescaline: Color.green
        case .cannabis: Color.mint
        case .other: Color.gray
        }
    }

    var initials: String {
        switch self {
        case .ketamine: "K"
        case .psilocybin: "P"
        case .lsd: "L"
        case .mdma: "MD"
        case .dmt: "D"
        case .ayahuasca: "A"
        case .mescaline: "ME"
        case .cannabis: "C"
        case .other: "O"
        }
    }
}
