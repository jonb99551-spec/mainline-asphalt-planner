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
}

