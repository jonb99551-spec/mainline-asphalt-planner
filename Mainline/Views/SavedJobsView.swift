import SwiftUI

struct SavedJobsView: View {
    @EnvironmentObject private var store: JobStore

    var body: some View {
        Group {
            if store.jobs.isEmpty {
                ContentUnavailableView(
                    "No Saved Jobs",
                    systemImage: "folder",
                    description: Text("Save a daily plan and it will stay on this iPhone for quick field access.")
                )
            } else {
                List {
                    ForEach(store.jobs) { job in
                        NavigationLink {
                            CalculatorView(estimate: job)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(job.jobName).font(.headline)
                                    Spacer()
                                    Text("\(AppFormat.number(job.plannedTons)) tons").font(.headline).foregroundStyle(.orange)
                                }
                                Text("\(Stationing.string(job.startStationFeet))–\(Stationing.string(job.endStationFeet)) · \(job.pavingTrucksNeeded) paving trucks")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text(job.updatedAt, format: .dateTime.month().day().year())
                                    .font(.caption).foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .onDelete(perform: store.delete)
                }
            }
        }
        .navigationTitle("Saved Plans")
    }
}
