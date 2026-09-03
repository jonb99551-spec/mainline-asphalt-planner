import Foundation

struct Estimate: Codable, Identifiable, Equatable {
    var id = UUID()
    var createdAt = Date()
    var updatedAt = Date()
    var jobName = "Today's Paving Plan"
    var location = ""
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
