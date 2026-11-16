import Foundation
import Combine
@MainActor final class RepairStore: ObservableObject {
    @Published var records: [RepairRecord] = [] { didSet { save() } }
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("repair-records.json")
    }
    init() {
        if let data = try? Data(contentsOf: fileURL),
           let value = try? JSONDecoder().decode([RepairRecord].self, from: data) { records = value }
    }
    func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
