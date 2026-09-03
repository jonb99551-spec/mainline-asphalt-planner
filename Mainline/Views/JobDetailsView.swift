import SwiftUI

struct JobDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var estimate: Estimate

    var body: some View {
        NavigationStack {
            Form {
                Section("Job") {
                    TextField("Job name", text: $estimate.jobName)
                    TextField("Project location", text: $estimate.location)
                }
                Section("Scope notes") {
                    TextField("Mix, lane, crew, traffic notes…", text: $estimate.notes, axis: .vertical)
                        .lineLimit(3...7)
                }
            }
            .navigationTitle("Job Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
