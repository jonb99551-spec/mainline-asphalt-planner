import SwiftUI

struct DailyReportView: View {
    @Environment(\.dismiss) private var dismiss
    let estimate: Estimate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MAIN LINE ASPHALT").font(.title.bold()).foregroundStyle(.orange)
                        Text("DAILY REPORT").font(.caption.bold()).tracking(1.4)
                    }
                    Spacer()
                    Text(estimate.reportDate, style: .date).font(.subheadline).foregroundStyle(.secondary)
                }

                reportSection("Project Information") {
                    if hasValue(estimate.jobName) { projectRow("Project Name", estimate.jobName, emphasized: true) }
                    if hasValue(estimate.projectNumber) { projectRow("Project Number", estimate.projectNumber) }
                    if hasValue(estimate.location) { projectRow("Project Location", estimate.location) }
                    projectRow("Report Date", estimate.reportDate.formatted(date: .long, time: .omitted))
                    if hasValue(estimate.contractorCompany) { projectRow("Contractor / Company", estimate.contractorCompany) }
                    if hasValue(estimate.inspectorQCTechnician) { projectRow("Inspector / QC Technician", estimate.inspectorQCTechnician) }
                    if hasValue(estimate.foremanSuperintendent) { projectRow("Foreman / Superintendent", estimate.foremanSuperintendent) }
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

                if hasValue(estimate.notes) { reportSection("Notes") { Text(estimate.notes) } }

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

    private func projectRow(_ label: String, _ value: String, emphasized: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(emphasized ? .title2.bold() : .body)
        }
    }

    private func hasValue(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var reportText: String {
        var lines = ["MAIN LINE ASPHALT", "DAILY REPORT", ""]
        appendIfPresent("Project Name", estimate.jobName, to: &lines)
        appendIfPresent("Project Number", estimate.projectNumber, to: &lines)
        appendIfPresent("Project Location", estimate.location, to: &lines)
        lines.append("Report Date: \(estimate.reportDate.formatted(date: .long, time: .omitted))")
        appendIfPresent("Contractor / Company", estimate.contractorCompany, to: &lines)
        appendIfPresent("Inspector / QC Technician", estimate.inspectorQCTechnician, to: &lines)
        appendIfPresent("Foreman / Superintendent", estimate.foremanSuperintendent, to: &lines)
        lines += [
            "",
            "PAVING / QC REPORT",
            "Station: \(Stationing.string(estimate.startStationFeet)) to \(Stationing.string(estimate.endStationFeet))",
            "Planned: \(AppFormat.number(estimate.plannedTons)) tons at \(AppFormat.number(estimate.desiredSpreadRate, digits: 0)) lb/SY",
            "Total delivered: \(AppFormat.number(estimate.totalTonsDelivered)) tons",
            "Waste / leftover: \(AppFormat.number(estimate.countedWasteTons)) tons (\(AppFormat.number(estimate.wastePercentage, digits: 1))%)",
            "Tons placed: \(AppFormat.number(estimate.placedTons)) tons",
            "Gross rate including waste: \(AppFormat.number(estimate.grossFinalSpreadRate, digits: 0)) lb/SY",
            "FINAL PLACED SPREAD RATE: \(AppFormat.number(estimate.netFinalSpreadRate, digits: 0)) lb/SY"
        ]
        if hasValue(estimate.notes) { lines += ["", "Notes: \(estimate.notes.trimmingCharacters(in: .whitespacesAndNewlines))"] }
        return lines.joined(separator: "\n")
    }

    private func appendIfPresent(_ label: String, _ value: String, to lines: inout [String]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { lines.append("\(label): \(trimmed)") }
    }
}
