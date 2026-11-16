import SwiftUI
struct ContentView: View {
    @EnvironmentObject var store: RepairStore
    @State private var editor: RepairRecord?
    @State private var search = ""
    private var rows: [RepairRecord] {
        store.records.filter {
            search.isEmpty || [$0.brand,$0.model,$0.imei,$0.issue].joined(separator:" ").localizedCaseInsensitiveContains(search)
        }.sorted { $0.date > $1.date }
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(rows) { item in
                    Button { editor = item } label: {
                        VStack(alignment:.leading, spacing:5) {
                            HStack { Text("\(item.brand) \(item.model)").font(.headline); Spacer(); Text(item.status).font(.caption).foregroundStyle(.secondary) }
                            Text(item.issue).foregroundStyle(.primary)
                            Text(item.date.formatted(date:.abbreviated,time:.omitted)).font(.caption).foregroundStyle(.secondary)
                        }
                    }.buttonStyle(.plain)
                }.onDelete { offsets in
                    let ids = offsets.map { rows[$0].id }
                    store.records.removeAll { ids.contains($0.id) }
                }
            }
            .searchable(text:$search,prompt:"搜尋品牌、型號、IMEI 或故障")
            .navigationTitle("手機維修管家")
            .toolbar {
                ToolbarItem(placement:.topBarLeading) { EditButton() }
                ToolbarItem(placement:.topBarTrailing) { Button { editor = RepairRecord() } label: { Image(systemName:"plus") } }
            }
            .sheet(item:$editor) { item in
                RecordEditor(record:item) { changed in
                    if let i = store.records.firstIndex(where:{$0.id == changed.id}) { store.records[i] = changed }
                    else { store.records.append(changed) }
                }
            }
        }
    }
}
struct RecordEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var record: RepairRecord
    let onSave: (RepairRecord)->Void
    private let statuses = ["待維修","維修中","待料","已完成","已交付"]
    var body: some View {
        NavigationStack {
            Form {
                Section("設備資料") {
                    TextField("品牌",text:$record.brand)
                    TextField("型號",text:$record.model)
                    TextField("IMEI / 序號",text:$record.imei)
                    DatePicker("日期",selection:$record.date,displayedComponents:.date)
                }
                Section("維修內容") {
                    Picker("狀態",selection:$record.status) { ForEach(statuses,id:\.self) { Text($0) } }
                    TextField("故障描述",text:$record.issue,axis:.vertical)
                    TextField("更換零件",text:$record.parts,axis:.vertical)
                }
                Section("費用與備註") {
                    TextField("零件成本",text:$record.cost).keyboardType(.decimalPad)
                    TextField("維修收費",text:$record.fee).keyboardType(.decimalPad)
                    TextField("保固期限",text:$record.warranty)
                    TextField("備註",text:$record.notes,axis:.vertical)
                }
            }
            .navigationTitle("維修紀錄").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.cancellationAction) { Button("取消"){dismiss()} }
                ToolbarItem(placement:.confirmationAction) {
                    Button("儲存"){onSave(record);dismiss()}
                        .disabled(record.brand.isEmpty && record.model.isEmpty && record.issue.isEmpty)
                }
            }
        }
    }
}
