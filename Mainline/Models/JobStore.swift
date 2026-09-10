import Foundation

@MainActor
final class JobStore: ObservableObject {
    @Published private(set) var jobs: [Estimate] = []
    @Published private(set) var currentReport = Estimate()

    private let saveURL: URL
    private let currentReportURL: URL
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = support.appendingPathComponent("Mainline", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        saveURL = folder.appendingPathComponent("saved-jobs.json")
        currentReportURL = folder.appendingPathComponent("current-report.json")
        load()
        loadCurrentReport()
    }

    func updateCurrentReport(_ estimate: Estimate) {
        currentReport = estimate
        persistCurrentReport()
    }

    @discardableResult
    func startNewReport() -> Estimate {
        let cleanReport = Estimate.blankReport()
        currentReport = cleanReport
        persistCurrentReport()
        return cleanReport
    }

    func save(_ estimate: Estimate) {
        var copy = estimate
        copy.updatedAt = Date()
        if let index = jobs.firstIndex(where: { $0.id == copy.id }) {
            jobs[index] = copy
        } else {
            jobs.insert(copy, at: 0)
        }
        jobs.sort { $0.updatedAt > $1.updatedAt }
        persist()
    }

    func delete(at offsets: IndexSet) {
        jobs.remove(atOffsets: offsets)
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        jobs = (try? decoder.decode([Estimate].self, from: data)) ?? []
    }

    private func loadCurrentReport() {
        guard let data = try? Data(contentsOf: currentReportURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        currentReport = (try? decoder.decode(Estimate.self, from: data)) ?? Estimate()
    }

    private func persist() {
        guard let data = try? encoder.encode(jobs) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private func persistCurrentReport() {
        guard let data = try? encoder.encode(currentReport) else { return }
        try? data.write(to: currentReportURL, options: .atomic)
    }
}
