//
//  QuanLyNXBView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct QuanLyNXBView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \NhaXuatBan.tenNXB)
    private var dsNXB: [NhaXuatBan]
    
    @State private var showingAddAlert: Bool = false
    @State private var tenMoi: String = ""
    
    var body: some View {
        List {
            Section(footer: Text("Ghi chú: Khi xóa Nhà xuất bản, liên kết trong sách sẽ được gỡ an toàn.")) {
                ForEach(dsNXB, id: \.maNXB) { nxb in
                    HStack {
                        Text(nxb.tenNXB)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(nxb.dsSach.count) sách")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .onDelete(perform: xoaNXB)
            }
        }
        .navigationTitle("Nhà Xuất Bản")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    tenMoi = ""
                    showingAddAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Thêm Nhà Xuất Bản Mới", isPresented: $showingAddAlert) {
            TextField("Tên NXB...", text: $tenMoi)
            Button("Thêm") {
                if !tenMoi.trimmingCharacters(in: .whitespaces).isEmpty {
                    let nxb = NhaXuatBan(tenNXB: tenMoi.trimmingCharacters(in: .whitespaces))
                    modelContext.insert(nxb)
                    try? modelContext.save()
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
    
    private func xoaNXB(at offsets: IndexSet) {
        for index in offsets {
            let item = dsNXB[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}
