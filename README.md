# Mainline Asphalt Planner

A clean, offline-first SwiftUI iPhone daily production planner for asphalt paving and milling. No account, server, analytics, or network connection is required.

## Open and run

1. Install Xcode 15 or newer.
2. Open `Mainline.xcodeproj`.
3. Select the **Mainline** scheme and an iPhone simulator.
4. Press **Run** (⌘R).

For installation on a physical iPhone, select the app target, open **Signing & Capabilities**, choose your Apple Developer team, and use a unique bundle identifier if Xcode requests one.

## Regenerating the project

The checked-in project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate
```

## Planner features

- Station-to-station paving runs using standard `00+00` notation
- Cumulative target tons at every 100-foot station
- Paver production, planned duration, truck cycle, and required truck count
- Milling tonnage and required truck count using speed, depth, and capacity
- Live yield tracking from current station and actual tons laid
- Automatic remainder spread-rate recommendation to finish on target
- End-of-day delivered tons, waste, placed tons, and final net spread rate
- Shareable daily closeout report showing gross yield and waste-adjusted yield

## Planning assumptions

- Area (SY) = station length (LF) × width (FT) ÷ 9
- Tons = area (SY) × desired spread rate (lb/SY) ÷ 2,000
- Truck cycles include round-trip haul time, plant/turn time, and machine load/unload time
- Required trucks round up to the next whole truck
- Milling tonnage assumes 145 lb/CF in-place density
- The live tracker compares actual cumulative tons with target cumulative tons, then calculates the spread rate needed across the remaining area

Saved jobs are encoded as JSON in the app's Application Support folder and remain only on the device.

## Before App Store submission

Set the final bundle identifier and signing team, add store screenshots and hosted support/privacy URLs, then validate the archive before submission.
