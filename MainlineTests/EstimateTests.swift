import XCTest
@testable import Mainline

final class EstimateTests: XCTestCase {
    func testDefaultTonnage() {
        let plan = Estimate()
        XCTAssertEqual(plan.lengthFeet, 5_000)
        XCTAssertEqual(plan.areaSquareYards, 2_222.222, accuracy: 0.001)
        XCTAssertEqual(plan.plannedTons, 316.667, accuracy: 0.001)
    }

    func testAscendingStations() {
        var plan = Estimate()
        plan.startStationFeet = 1_250
        plan.endStationFeet = 1_575
        XCTAssertEqual(plan.stationTargets.map(\.stationFeet), [1_250, 1_300, 1_400, 1_500, 1_575])
        plan.currentStationFeet = 1_400
        XCTAssertEqual(plan.completedFeet, 150)
    }

    func testDescendingStations() {
        var plan = Estimate()
        plan.startStationFeet = 5_000
        plan.endStationFeet = 4_550
        XCTAssertEqual(plan.lengthFeet, 450)
        XCTAssertEqual(plan.stationTargets.map(\.stationFeet), [5_000, 4_900, 4_800, 4_700, 4_600, 4_550])
        plan.currentStationFeet = 4_800
        XCTAssertEqual(plan.completedFeet, 200)
    }

    func testWasteAdjustedFinalSpread() {
        var plan = Estimate()
        plan.startStationFeet = 0
        plan.endStationFeet = 900
        plan.widthFeet = 10
        plan.totalTonsDelivered = 150
        plan.wasteTons = 5
        XCTAssertEqual(plan.areaSquareYards, 1_000)
        XCTAssertEqual(plan.placedTons, 145)
        XCTAssertEqual(plan.grossFinalSpreadRate, 300)
        XCTAssertEqual(plan.netFinalSpreadRate, 290)
        XCTAssertEqual(plan.wastePercentage, 3.333, accuracy: 0.001)
    }

    func testStationParsing() {
        XCTAssertEqual(Stationing.feet(from: "50+25"), 5_025)
        XCTAssertEqual(Stationing.string(5_025), "50+25")
    }

    func testLegacySavedReportLoadsWithSafeProjectDefaults() throws {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let legacy: [String: Any] = [
            "id": UUID().uuidString,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: createdAt),
            "jobName": "Legacy paving plan",
            "location": "Route 10",
            "notes": "Existing note",
            "startStationFeet": 0,
            "endStationFeet": 1000,
            "widthFeet": 12,
            "desiredSpreadRate": 285
        ]
        let data = try JSONSerialization.data(withJSONObject: legacy)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(Estimate.self, from: data)

        XCTAssertEqual(decoded.jobName, "Legacy paving plan")
        XCTAssertEqual(decoded.reportDate.timeIntervalSince1970, createdAt.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(decoded.projectNumber, "")
        XCTAssertEqual(decoded.contractorCompany, "")
        XCTAssertEqual(decoded.inspectorQCTechnician, "")
        XCTAssertEqual(decoded.foremanSuperintendent, "")
        XCTAssertEqual(decoded.plannedTons, 190, accuracy: 0.001)
    }

    func testBlankReportClearsEntriesAndUsesRequestedDate() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let report = Estimate.blankReport(on: date)

        XCTAssertEqual(report.reportDate, date)
        XCTAssertEqual(report.jobName, "")
        XCTAssertEqual(report.location, "")
        XCTAssertEqual(report.endStationFeet, 0)
        XCTAssertEqual(report.desiredSpreadRate, 0)
        XCTAssertEqual(report.totalTonsDelivered, 0)
        XCTAssertEqual(report.wasteTons, 0)
    }
}
