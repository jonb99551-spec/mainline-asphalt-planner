import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
    }
}

struct NumberField: View {
    let title: String
    let unit: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: $value, formatter: AppFormat.number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 110)
                .textFieldStyle(.roundedBorder)
            Text(unit)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .leading)
        }
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    var emphasized = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(emphasized ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(emphasized ? .title3.bold() : .body.weight(.semibold))
                .monospacedDigit()
        }
    }
}

struct StationField: View {
    let title: String
    @Binding var feet: Double
    @State private var text = ""

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0+00", text: $text)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 120)
                .onChange(of: text) { _, newValue in
                    if let parsed = Stationing.feet(from: newValue) { feet = parsed }
                }
        }
        .onAppear { text = Stationing.string(feet) }
        .onChange(of: feet) { _, newValue in
            if Stationing.feet(from: text) != newValue { text = Stationing.string(newValue) }
        }
    }
}
