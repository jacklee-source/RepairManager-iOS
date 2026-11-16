import Foundation
struct RepairRecord: Identifiable, Codable {
    var id = UUID()
    var brand = ""
    var model = ""
    var imei = ""
    var date = Date()
    var status = "待維修"
    var issue = ""
    var parts = ""
    var cost = ""
    var fee = ""
    var warranty = ""
    var notes = ""
}
