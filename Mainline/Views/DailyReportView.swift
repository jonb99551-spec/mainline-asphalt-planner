import SwiftUI

struct DailyReportView: View {
    @Environment(\.dismiss) private var dismiss
    let estimate: Estimate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MAINLINE").font(.title.bold()).foregroundStyle(.orange)
                        Text("ASPHALT DAILY REPORT").font(.caption.bold()).tracking(1.4)
                    }
                    Spacer()
                    Text(Date.now, style: .date).font(.subheadline).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(estimate.jobName).font(.title2.bold())
                    if !estimate.location.isEmpty { Label(estimate.location, systemImage: "mappin.and.ellipse") }
                    Text("Station \(Stationing.string(estimate.startStationFeet)) to \(Stationing.string(estimate.endStationFeet))")
                        .foregroundStyle(.secondary)
                }

                reportSection("Planned") {
                    ResultRow(label: "Length / width", value: "\(AppFormat.number(estimate.lengthFeet, digits: 0)) LF / \(AppFormat.number(estimate.widthFeet)) FT")
                    ResultRow(label: "Desired spread", value: "\(AppFormat.number(estimate.desiredSpreadRate, digits: 0)) lb/SY")
                    ResultRow(label: "Planned tons", value: "\(AppFormat.number(estimate.plannedTons)) tons")
                }

                reportSection("Final Tons & Waste") {
                    ResultRow(label: "Total delivered", value: "\(AppFormat.number(estimate.totalTonsDelivered)) tons")
                    ResultRow(label: "Waste / leftover", value: "\(AppFormat.number(estimate.countedWasteTons)) tons")
                    ResultRow(label: "Waste percentage", value: "\(AppFormat.number(estimate.wastePercentage, digits: 1))%")
                    ResultRow(label: "Actually placed", value: "\(AppFormat.number(estimate.placedTons)) tons")
                }

                reportSection("Final Yield") {
                    ResultRow(label: "Gross rate incl. waste", value: "\(AppFormat.number(estimate.grossFinalSpreadRate, digits: 0)) lb/SY")
                    ResultRow(label: "Net placed spread rate", value: "\(AppFormat.number(estimate.netFinalSpreadRate, digits: 0)) lb/SY", emphasized: true)
                    ResultRow(label: estimate.finalTonnageVariance >= 0 ? "Placed over plan" : "Placed under plan",
                              value: "\(AppFormat.number(abs(estimate.finalTonnageVariance))) tons")
                }

                if !estimate.notes.isEmpty { reportSection("Crew Notes") { Text(estimate.notes) } }

                Text("Gross rate includes all delivered material. Net placed spread rate removes reported waste or leftover material.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("Daily Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            ToolbarItem(placement: .primaryAction) { ShareLink(item: reportText) { Image(systemName: "square.and.arrow.up") } }
        }
    }

    private func reportSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased()).font(.caption.bold()).foregroundStyle(.orange).tracking(1)
            content()
        }
    }

    private var reportText: String {
        """
        MAINLINE ASPHALT DAILY REPORT
        \(estimate.jobName)
        \(estimate.location)
        Station: \(Stationing.string(estimate.startStationFeet)) to \(Stationing.string(estimate.endStationFeet))

        Planned: \(AppFormat.number(estimate.plannedTons)) tons at \(AppFormat.number(estimate.desiredSpreadRate, digits: 0)) lb/SY
        Total delivered: \(AppFormat.number(estimate.totalTonsDelivered)) tons
        Waste / leftover: \(AppFormat.number(estimate.countedWasteTons)) tons (\(AppFormat.number(estimate.wastePercentage, digits: 1))%)
        Tons placed: \(AppFormat.number(estimate.placedTons)) tons
        Gross rate including waste: \(AppFormat.number(estimate.grossFinalSpreadRate, digits: 0)) lb/SY
        FINAL PLACED SPREAD RATE: \(AppFormat.number(estimate.netFinalSpreadRate, digits: 0)) lb/SY

        Notes: \(estimate.notes)
        """
    }
}
