import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject private var store: JobStore
    @State private var estimate: Estimate
    @State private var showingDetails = false
    @State private var showingStationPlan = false
    @State private var showingDailyReport = false
    @State private var savedConfirmation = false

    init(estimate: Estimate = Estimate()) { _estimate = State(initialValue: estimate) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header; stationCard; pavingCard; haulCard; pavingResults; millingCard; trackerCard; closeoutCard; saveButton
            }.padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Daily Asphalt Planner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Job Info") { showingDetails = true } } }
        .sheet(isPresented: $showingDetails) { JobDetailsView(estimate: $estimate) }
        .sheet(isPresented: $showingStationPlan) { NavigationStack { StationPlanView(estimate: estimate) } }
        .sheet(isPresented: $showingDailyReport) { NavigationStack { DailyReportView(estimate: estimate) } }
        .alert("Plan Saved", isPresented: $savedConfirmation) { Button("OK", role: .cancel) { } }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "road.lanes").font(.title2).foregroundStyle(.white)
                .frame(width: 46, height: 46).background(.orange, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(estimate.jobName).font(.headline)
                Text("Plan the run. Keep the operation moving.").font(.caption).foregroundStyle(.secondary)
            }; Spacer()
        }
    }

    private var stationCard: some View {
        SectionCard(title: "Run & Stationing") {
            StationField(title: "Start station", feet: $estimate.startStationFeet)
                .onChange(of: estimate.startStationFeet) { oldValue, newValue in
                    if estimate.currentStationFeet == oldValue ||
                        estimate.currentStationFeet < min(newValue, estimate.endStationFeet) ||
                        estimate.currentStationFeet > max(newValue, estimate.endStationFeet) {
                        estimate.currentStationFeet = newValue
                    }
                }
            Divider()
            StationField(title: "End station", feet: $estimate.endStationFeet); Divider()
            NumberField(title: "Paving width", unit: "FT", value: $estimate.widthFeet)
            ResultRow(label: "Run length", value: "\(AppFormat.number(estimate.lengthFeet, digits: 0)) LF")
            ResultRow(label: "Paving direction", value: estimate.isDescending ? "Stationing down ↓" : "Stationing up ↑")
        }
    }

    private var pavingCard: some View {
        SectionCard(title: "Paving Operation") {
            NumberField(title: "Desired spread", unit: "lb/SY", value: $estimate.desiredSpreadRate); Divider()
            NumberField(title: "Paver speed", unit: "FT/MIN", value: $estimate.paverSpeedFeetPerMinute); Divider()
            NumberField(title: "Truck capacity", unit: "TON", value: $estimate.truckCapacityTons)
        }
    }

    private var haulCard: some View {
        SectionCard(title: "Haul Cycle") {
            NumberField(title: "One-way to plant", unit: "MI", value: $estimate.plantDistanceMiles); Divider()
            NumberField(title: "Average haul speed", unit: "MPH", value: $estimate.averageHaulSpeedMPH); Divider()
            NumberField(title: "Load + turn time", unit: "MIN", value: $estimate.plantAndTurnMinutes)
            Text("Truck count includes round-trip drive, plant/turn time, and unloading at production speed.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var pavingResults: some View {
        SectionCard(title: "Paving Plan") {
            ResultRow(label: "Planned tonnage", value: "\(AppFormat.number(estimate.plannedTons)) tons", emphasized: true)
            ResultRow(label: "Production rate", value: "\(AppFormat.number(estimate.pavingTonsPerMinute, digits: 2)) ton/min")
            ResultRow(label: "Paving time", value: duration(estimate.pavingDurationMinutes))
            ResultRow(label: "Truck cycle", value: duration(estimate.pavingCycleMinutes)); Divider()
            ResultRow(label: "Trucks to keep paver fed", value: "\(estimate.pavingTrucksNeeded) trucks", emphasized: true)
            Button { showingStationPlan = true } label: {
                Label("100-Foot Station Tonnage Plan", systemImage: "list.number").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent).tint(.orange)
        }
    }

    private var millingCard: some View {
        SectionCard(title: "Milling Operation") {
            NumberField(title: "Mill speed", unit: "FT/MIN", value: $estimate.millingSpeedFeetPerMinute); Divider()
            NumberField(title: "Cut depth", unit: "IN", value: $estimate.millingDepthInches); Divider()
            NumberField(title: "Mill truck capacity", unit: "TON", value: $estimate.millTruckCapacityTons); Divider()
            ResultRow(label: "Estimated millings", value: "\(AppFormat.number(estimate.millTotalTons)) tons")
            ResultRow(label: "Trucks to keep mill moving", value: "\(estimate.millingTrucksNeeded) trucks", emphasized: true)
            Text("Millings use an estimated in-place density of 145 lb/CF.").font(.caption).foregroundStyle(.secondary)
        }
    }

    private var trackerCard: some View {
        SectionCard(title: "Live Yield Tracker") {
            StationField(title: "Current station", feet: $estimate.currentStationFeet); Divider()
            NumberField(title: "Actual tons laid", unit: "TON", value: $estimate.actualTonsUsed); Divider()
            ResultRow(label: "Target tons here", value: "\(AppFormat.number(estimate.targetTonsAtCurrentStation)) tons")
            ResultRow(label: "Actual spread so far", value: "\(AppFormat.number(estimate.actualSpreadRate, digits: 0)) lb/SY")
            ResultRow(label: estimate.tonVariance >= 0 ? "Over target" : "Under target", value: "\(AppFormat.number(abs(estimate.tonVariance))) tons")
            trackerGuidance
        }
    }

    @ViewBuilder private var trackerGuidance: some View {
        if estimate.completedFeet <= 0 {
            Text("Enter the current station and total tons laid to check yield.").font(.subheadline).foregroundStyle(.secondary)
        } else if estimate.remainingAreaSY <= 0 {
            Text("Run complete. Final average: \(AppFormat.number(estimate.actualSpreadRate, digits: 0)) lb/SY.")
                .font(.headline).foregroundStyle(.orange)
        } else {
            let change = estimate.requiredRemainingSpreadRate - estimate.desiredSpreadRate
            VStack(alignment: .leading, spacing: 5) {
                Text("Run the remainder at \(AppFormat.number(estimate.requiredRemainingSpreadRate, digits: 0)) lb/SY").font(.headline)
                Text(change > 1 ? "Bump it up \(AppFormat.number(change, digits: 0)) lb/SY to finish on target."
                     : change < -1 ? "Back it down \(AppFormat.number(abs(change), digits: 0)) lb/SY to finish on target."
                     : "You are on yield. Hold the planned spread rate.").font(.subheadline)
            }
            .foregroundStyle(change > 1 ? .red : change < -1 ? .blue : .green)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var saveButton: some View {
        Button { store.save(estimate); savedConfirmation = true } label: {
            Label("Save Daily Plan", systemImage: "square.and.arrow.down").frame(maxWidth: .infinity)
        }.buttonStyle(.bordered).controlSize(.large)
    }

    private var closeoutCard: some View {
        SectionCard(title: "End-of-Day Closeout") {
            NumberField(title: "Total tons delivered", unit: "TON", value: $estimate.totalTonsDelivered)
            Divider()
            NumberField(title: "Waste / leftover", unit: "TON", value: $estimate.wasteTons)
            Divider()
            ResultRow(label: "Tons actually placed", value: "\(AppFormat.number(estimate.placedTons)) tons")
            ResultRow(label: "Waste", value: "\(AppFormat.number(estimate.wastePercentage, digits: 1))%")
            ResultRow(label: "Gross rate incl. waste", value: "\(AppFormat.number(estimate.grossFinalSpreadRate, digits: 0)) lb/SY")
            ResultRow(label: "Final placed spread rate", value: "\(AppFormat.number(estimate.netFinalSpreadRate, digits: 0)) lb/SY", emphasized: true)
            Button { showingDailyReport = true } label: {
                Label("View Daily Report", systemImage: "doc.text").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(.orange)
            .disabled(estimate.totalTonsDelivered <= 0)
        }
    }

    private func duration(_ minutes: Double) -> String {
        guard minutes.isFinite, minutes > 0 else { return "—" }
        let total = Int(minutes.rounded())
        return total >= 60 ? "\(total / 60) hr \(total % 60) min" : "\(total) min"
    }
}
