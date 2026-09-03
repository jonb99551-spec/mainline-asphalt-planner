import SwiftUI

struct StationPlanView: View {
    @Environment(\.dismiss) private var dismiss
    let estimate: Estimate

    var body: some View {
        List {
            Section {
                HStack { Text("Station").fontWeight(.bold); Spacer(); Text("Cumulative Tons").fontWeight(.bold) }
                ForEach(estimate.stationTargets) { target in
                    HStack {
                        Text(Stationing.string(target.stationFeet)).monospacedDigit()
                        Spacer()
                        Text(AppFormat.number(target.cumulativeTons)).fontWeight(.semibold).monospacedDigit()
                    }
                }
            } footer: {
                Text("Targets are cumulative from \(Stationing.string(estimate.startStationFeet)) at \(AppFormat.number(estimate.desiredSpreadRate, digits: 0)) lb/SY and \(AppFormat.number(estimate.widthFeet)) FT wide.")
            }
        }
        .navigationTitle("Station Tonnage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            ToolbarItem(placement: .primaryAction) { ShareLink(item: planText) { Image(systemName: "square.and.arrow.up") } }
        }
    }

    private var planText: String {
        let rows = estimate.stationTargets.map { "\(Stationing.string($0.stationFeet))\t\(AppFormat.number($0.cumulativeTons)) tons" }.joined(separator: "\n")
        return "\(estimate.jobName)\n100-FT STATION TONNAGE PLAN\n\n\(rows)\n\nTotal: \(AppFormat.number(estimate.plannedTons)) tons"
    }
}
