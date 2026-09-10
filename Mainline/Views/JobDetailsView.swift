import SwiftUI
import UIKit

struct JobDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var estimate: Estimate

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Information") {
                    DatePicker("Report date", selection: $estimate.reportDate, displayedComponents: .date)
                    TextField("Project name", text: $estimate.jobName)
                    TextField("Project number", text: $estimate.projectNumber)
                    TextField("Project location", text: $estimate.location)
                    TextField("Contractor / Company", text: $estimate.contractorCompany)
                    TextField("Inspector / QC Technician", text: $estimate.inspectorQCTechnician)
                    TextField("Foreman / Superintendent", text: $estimate.foremanSuperintendent)
                }
                Section("Optional Notes") {
                    TextField("Mix, lane, crew, traffic notes…", text: $estimate.notes, axis: .vertical)
                        .lineLimit(3...7)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Job Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}
