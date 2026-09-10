import Foundation

struct Estimate: Codable, Identifiable, Equatable {
    var id = UUID()
    var createdAt = Date()
    var updatedAt = Date()
    var reportDate = Date()
    var jobName = "Today's Paving Plan"
    var projectNumber = ""
    var location = ""
    var contractorCompany = ""
    var inspectorQCTechnician = ""
    var foremanSuperintendent = ""
    var notes = ""

    // Stationing is stored in feet. 5,000 feet displays as 50+00.
    var startStationFeet = 0.0
    var endStationFeet = 5_000.0
    var widthFeet = 4.0
    var desiredSpreadRate = 285.0
    var paverSpeedFeetPerMinute = 25.0
    var truckCapacityTons = 21.0
    var plantDistanceMiles = 20.0
    var averageHaulSpeedMPH = 45.0
    var plantAndTurnMinutes = 20.0
    var millingSpeedFeetPerMinute = 35.0
    var millingDepthInches = 2.0
    var millTruckCapacityTons = 21.0
    var currentStationFeet = 0.0
    var actualTonsUsed = 0.0
    var totalTonsDelivered = 0.0
    var wasteTons = 0.0

    init() {}

    static func blankReport(on date: Date = Date()) -> Estimate {
        var report = Estimate()
        report.createdAt = date
        report.updatedAt = date
        report.reportDate = date
        report.jobName = ""
        report.projectNumber = ""
        report.location = ""
        report.contractorCompany = ""
        report.inspectorQCTechnician = ""
        report.foremanSuperintendent = ""
        report.notes = ""
        report.startStationFeet = 0
        report.endStationFeet = 0
        report.widthFeet = 0
        report.desiredSpreadRate = 0
        report.paverSpeedFeetPerMinute = 0
        report.truckCapacityTons = 0
        report.plantDistanceMiles = 0
        report.averageHaulSpeedMPH = 0
        report.plantAndTurnMinutes = 0
        report.millingSpeedFeetPerMinute = 0
        report.millingDepthInches = 0
        report.millTruckCapacityTons = 0
        report.currentStationFeet = 0
        report.actualTonsUsed = 0
        report.totalTonsDelivered = 0
        report.wasteTons = 0
        return report
    }

    private enum CodingKeys: String, CodingKey {
        case id, createdAt, updatedAt, reportDate, jobName, projectNumber, location
        case contractorCompany, inspectorQCTechnician, foremanSuperintendent, notes
        case startStationFeet, endStationFeet, widthFeet, desiredSpreadRate
        case paverSpeedFeetPerMinute, truckCapacityTons, plantDistanceMiles
        case averageHaulSpeedMPH, plantAndTurnMinutes, millingSpeedFeetPerMinute
        case millingDepthInches, millTruckCapacityTons, currentStationFeet
        case actualTonsUsed, totalTonsDelivered, wasteTons
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try values.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
        reportDate = try values.decodeIfPresent(Date.self, forKey: .reportDate) ?? createdAt
        jobName = try values.decodeIfPresent(String.self, forKey: .jobName) ?? "Today's Paving Plan"
        projectNumber = try values.decodeIfPresent(String.self, forKey: .projectNumber) ?? ""
        location = try values.decodeIfPresent(String.self, forKey: .location) ?? ""
        contractorCompany = try values.decodeIfPresent(String.self, forKey: .contractorCompany) ?? ""
        inspectorQCTechnician = try values.decodeIfPresent(String.self, forKey: .inspectorQCTechnician) ?? ""
        foremanSuperintendent = try values.decodeIfPresent(String.self, forKey: .foremanSuperintendent) ?? ""
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        startStationFeet = try values.decodeIfPresent(Double.self, forKey: .startStationFeet) ?? 0
        endStationFeet = try values.decodeIfPresent(Double.self, forKey: .endStationFeet) ?? 5_000
        widthFeet = try values.decodeIfPresent(Double.self, forKey: .widthFeet) ?? 4
        desiredSpreadRate = try values.decodeIfPresent(Double.self, forKey: .desiredSpreadRate) ?? 285
        paverSpeedFeetPerMinute = try values.decodeIfPresent(Double.self, forKey: .paverSpeedFeetPerMinute) ?? 25
        truckCapacityTons = try values.decodeIfPresent(Double.self, forKey: .truckCapacityTons) ?? 21
        plantDistanceMiles = try values.decodeIfPresent(Double.self, forKey: .plantDistanceMiles) ?? 20
        averageHaulSpeedMPH = try values.decodeIfPresent(Double.self, forKey: .averageHaulSpeedMPH) ?? 45
        plantAndTurnMinutes = try values.decodeIfPresent(Double.self, forKey: .plantAndTurnMinutes) ?? 20
        millingSpeedFeetPerMinute = try values.decodeIfPresent(Double.self, forKey: .millingSpeedFeetPerMinute) ?? 35
        millingDepthInches = try values.decodeIfPresent(Double.self, forKey: .millingDepthInches) ?? 2
        millTruckCapacityTons = try values.decodeIfPresent(Double.self, forKey: .millTruckCapacityTons) ?? 21
        currentStationFeet = try values.decodeIfPresent(Double.self, forKey: .currentStationFeet) ?? startStationFeet
        actualTonsUsed = try values.decodeIfPresent(Double.self, forKey: .actualTonsUsed) ?? 0
        totalTonsDelivered = try values.decodeIfPresent(Double.self, forKey: .totalTonsDelivered) ?? 0
        wasteTons = try values.decodeIfPresent(Double.self, forKey: .wasteTons) ?? 0
    }

    var isDescending: Bool { endStationFeet < startStationFeet }
    var direction: Double { isDescending ? -1 : 1 }
    var lengthFeet: Double { abs(endStationFeet - startStationFeet) }
    var areaSquareYards: Double { lengthFeet * max(widthFeet, 0) / 9 }
    var plannedTons: Double { areaSquareYards * max(desiredSpreadRate, 0) / 2_000 }
    var pavingTonsPerMinute: Double {
        max(paverSpeedFeetPerMinute, 0) * max(widthFeet, 0) / 9 * max(desiredSpreadRate, 0) / 2_000
    }
    var pavingUnloadMinutes: Double {
        guard pavingTonsPerMinute > 0 else { return 0 }
        return max(truckCapacityTons, 0) / pavingTonsPerMinute
    }
    var haulDriveMinutes: Double {
        guard averageHaulSpeedMPH > 0 else { return 0 }
        return plantDistanceMiles * 2 / averageHaulSpeedMPH * 60
    }
    var pavingCycleMinutes: Double { haulDriveMinutes + max(plantAndTurnMinutes, 0) + pavingUnloadMinutes }
    var pavingTrucksNeeded: Int {
        guard pavingUnloadMinutes > 0 else { return 0 }
        return Int(ceil(pavingCycleMinutes / pavingUnloadMinutes))
    }
    var pavingDurationMinutes: Double {
        guard paverSpeedFeetPerMinute > 0 else { return 0 }
        return lengthFeet / paverSpeedFeetPerMinute
    }

    // Approximate reclaimed asphalt weight using 145 lb/CF in-place density.
    var millingPoundsPerSquareYard: Double { max(millingDepthInches, 0) / 12 * 9 * 145 }
    var millTotalTons: Double { areaSquareYards * millingPoundsPerSquareYard / 2_000 }
    var millingTonsPerMinute: Double {
        max(millingSpeedFeetPerMinute, 0) * max(widthFeet, 0) / 9 * millingPoundsPerSquareYard / 2_000
    }
    var millingLoadMinutes: Double {
        guard millingTonsPerMinute > 0 else { return 0 }
        return max(millTruckCapacityTons, 0) / millingTonsPerMinute
    }
    var millingCycleMinutes: Double { haulDriveMinutes + max(plantAndTurnMinutes, 0) + millingLoadMinutes }
    var millingTrucksNeeded: Int {
        guard millingLoadMinutes > 0 else { return 0 }
        return Int(ceil(millingCycleMinutes / millingLoadMinutes))
    }

    var clampedCurrentStation: Double {
        min(max(currentStationFeet, min(startStationFeet, endStationFeet)), max(startStationFeet, endStationFeet))
    }
    var completedFeet: Double {
        let traveled = (clampedCurrentStation - startStationFeet) * direction
        return min(max(traveled, 0), lengthFeet)
    }
    var completedAreaSY: Double { completedFeet * max(widthFeet, 0) / 9 }
    var targetTonsAtCurrentStation: Double { completedAreaSY * max(desiredSpreadRate, 0) / 2_000 }
    var tonVariance: Double { actualTonsUsed - targetTonsAtCurrentStation }
    var actualSpreadRate: Double {
        guard completedAreaSY > 0 else { return 0 }
        return actualTonsUsed * 2_000 / completedAreaSY
    }
    var remainingAreaSY: Double { max(areaSquareYards - completedAreaSY, 0) }
    var remainingTonsToTarget: Double { max(plannedTons - actualTonsUsed, 0) }
    var requiredRemainingSpreadRate: Double {
        guard remainingAreaSY > 0 else { return 0 }
        return remainingTonsToTarget * 2_000 / remainingAreaSY
    }

    var countedWasteTons: Double { min(max(wasteTons, 0), max(totalTonsDelivered, 0)) }
    var placedTons: Double { max(totalTonsDelivered, 0) - countedWasteTons }
    var wastePercentage: Double {
        guard totalTonsDelivered > 0 else { return 0 }
        return countedWasteTons / totalTonsDelivered * 100
    }
    var grossFinalSpreadRate: Double {
        guard areaSquareYards > 0 else { return 0 }
        return max(totalTonsDelivered, 0) * 2_000 / areaSquareYards
    }
    var netFinalSpreadRate: Double {
        guard areaSquareYards > 0 else { return 0 }
        return placedTons * 2_000 / areaSquareYards
    }
    var finalTonnageVariance: Double { placedTons - plannedTons }

    var stationTargets: [StationTarget] {
        guard endStationFeet != startStationFeet else {
            return [StationTarget(stationFeet: startStationFeet, cumulativeTons: 0)]
        }
        var stations: [Double] = [startStationFeet]
        var next = isDescending
            ? (ceil(startStationFeet / 100) - 1) * 100
            : (floor(startStationFeet / 100) + 1) * 100
        while isDescending ? next > endStationFeet : next < endStationFeet {
            stations.append(next)
            next += 100 * direction
        }
        if stations.last != endStationFeet { stations.append(endStationFeet) }
        return stations.map { station in
            let feet = abs(station - startStationFeet)
            let tons = feet * max(widthFeet, 0) / 9 * max(desiredSpreadRate, 0) / 2_000
            return StationTarget(stationFeet: station, cumulativeTons: tons)
        }
    }
}

struct StationTarget: Identifiable {
    var id: Double { stationFeet }
    let stationFeet: Double
    let cumulativeTons: Double
}

enum Stationing {
    static func string(_ feet: Double) -> String {
        let rounded = Int(feet.rounded())
        let sign = rounded < 0 ? "-" : ""
        let absolute = abs(rounded)
        return "\(sign)\(absolute / 100)+\(String(format: "%02d", absolute % 100))"
    }

    static func feet(from text: String) -> Double? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
        if cleaned.contains("+") {
            let parts = cleaned.split(separator: "+", maxSplits: 1).map(String.init)
            guard parts.count == 2, let hundreds = Double(parts[0]), let remainder = Double(parts[1]) else { return nil }
            return hundreds * 100 + (hundreds < 0 ? -remainder : remainder)
        }
        return Double(cleaned)
    }
}
