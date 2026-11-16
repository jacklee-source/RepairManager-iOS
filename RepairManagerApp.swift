import SwiftUI
@main struct RepairManagerApp: App {
    @StateObject private var store = RepairStore()
    var body: some Scene { WindowGroup { ContentView().environmentObject(store) } }
}
