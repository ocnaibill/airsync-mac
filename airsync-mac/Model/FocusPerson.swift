import Foundation

struct FocusPerson: Codable, Identifiable, Equatable {
    var id = UUID()
    var displayName: String
    var identifiers: [String] // Nomes usados nos apps (WhatsApp, Discord, etc)

    static func == (lhs: FocusPerson, rhs: FocusPerson) -> Bool {
        lhs.id == rhs.id
    }
}
