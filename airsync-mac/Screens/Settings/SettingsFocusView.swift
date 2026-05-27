import SwiftUI

struct SettingsFocusView: View {
    @ObservedObject var appState = AppState.shared
    @State private var newPersonName: String = ""
    @State private var newAppPackage: String = ""
    @State private var expandedPersonId: UUID? = nil
    @State private var newIdentifier: String = ""

    var body: some View {
        VStack(spacing: 16) {
            // Main Toggle
            VStack {
                HStack {
                    Label("Custom Focus Mode", systemImage: "target")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $appState.isCustomFocusEnabled)
                        .toggleStyle(.switch)
                }
                Text("When enabled, only notifications from the apps or identities listed below will be shown.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(.background.opacity(0.3))
            .cornerRadius(12.0)

            if appState.isCustomFocusEnabled {
                // Focus People Section
                VStack(alignment: .leading, spacing: 10) {
                    Label("Allowed Identities (People/Groups)", systemImage: "person.2.fill")
                        .font(.subheadline)
                        .bold()

                    HStack {
                        TextField("New Person Name (e.g. Miguel)", text: $newPersonName)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: {
                            if !newPersonName.isEmpty {
                                let newPerson = FocusPerson(displayName: newPersonName, identifiers: [])
                                appState.focusPeople.append(newPerson)
                                newPersonName = ""
                                expandedPersonId = newPerson.id
                            }
                        }) {
                            Label("Add Person", systemImage: "person.badge.plus")
                        }
                        .glassButtonStyle()
                        .disabled(newPersonName.isEmpty)
                    }

                    if appState.focusPeople.isEmpty {
                        Text("No identities added yet.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 8) {
                            ForEach($appState.focusPeople) { $person in
                                PersonRowView(person: $person, isExpanded: expandedPersonId == person.id) {
                                    if expandedPersonId == person.id {
                                        expandedPersonId = nil
                                    } else {
                                        expandedPersonId = person.id
                                    }
                                } onDelete: {
                                    appState.focusPeople.removeAll { $0.id == person.id }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.background.opacity(0.3))
                .cornerRadius(12.0)

                // Allowed Apps Section
                VStack(alignment: .leading, spacing: 10) {
                    Label("Allowed Apps (Full Bypass)", systemImage: "app.badge.fill")
                        .font(.subheadline)
                        .bold()

                    HStack {
                        Picker("Select App", selection: $newAppPackage) {
                            Text("Select an app...").tag("")
                            ForEach(appState.androidApps.values.sorted(by: { $0.name < $1.name }), id: \.packageName) { app in
                                Text(app.name).tag(app.packageName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Button(action: {
                            if !newAppPackage.isEmpty && !appState.allowedFocusApps.contains(newAppPackage) {
                                appState.allowedFocusApps.append(newAppPackage)
                                newAppPackage = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(newAppPackage.isEmpty)
                    }

                    if appState.allowedFocusApps.isEmpty {
                        Text("No apps bypassed. Only notifications from allowed identities will be shown.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        FlowLayout(items: appState.allowedFocusApps) { package in
                            HStack(spacing: 4) {
                                if let app = appState.androidApps[package] {
                                    Text(app.name)
                                } else {
                                    Text(package)
                                }
                                Button(action: {
                                    appState.allowedFocusApps.removeAll { $0 == package }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(.background.opacity(0.3))
                .cornerRadius(12.0)
            }
        }
    }
}

struct PersonRowView: View {
    @Binding var person: FocusPerson
    var isExpanded: Bool
    var onToggleExpand: () -> Void
    var onDelete: () -> Void
    @State private var newIdentifier: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.accentColor)
                
                TextField("Display Name", text: $person.displayName)
                    .textFieldStyle(.plain)
                    .font(.body.bold())
                
                Spacer()
                
                Text("\(person.identifiers.count) identifiers")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: onToggleExpand) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Associated names/identifiers for this person across all apps:")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    HStack {
                        TextField("Add name, username or email...", text: $newIdentifier)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.small)
                        
                        Button(action: {
                            if !newIdentifier.isEmpty {
                                if !person.identifiers.contains(newIdentifier) {
                                    person.identifiers.append(newIdentifier)
                                }
                                newIdentifier = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .disabled(newIdentifier.isEmpty)
                    }

                    if person.identifiers.isEmpty {
                        Text("No identifiers added. This person will never match notifications.")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.orange)
                    } else {
                        FlowLayout(items: person.identifiers) { id in
                            HStack(spacing: 4) {
                                Text(id)
                                    .font(.caption)
                                Button(action: {
                                    person.identifiers.removeAll { $0 == id }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                        }
                    }
                }
                .padding(.leading, 24)
                .padding(.top, 4)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// Helper for wrapping items in a grid-like flow
struct FlowLayout<T: Hashable, Content: View>: View {
    let items: [T]
    let content: (T) -> Content

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > 300) { // arbitrary width limit
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
}

extension View {
    func glassButtonStyle() -> some View {
        self.padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(6)
            .buttonStyle(.plain)
    }
}
