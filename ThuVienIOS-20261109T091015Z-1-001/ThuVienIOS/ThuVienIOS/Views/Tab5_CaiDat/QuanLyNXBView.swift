//
//  QuanLyNXBView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.2 - Quản Lý Danh Mục Nhà Xuất Bản
//  CHỨC NĂNG:
//  - Hiển thị danh sách các Nhà xuất bản kèm số lượng đầu sách
//  - Nút (+) mở Alert thêm NXB mới
//  - Thao tác vuốt xóa NXB an toàn
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
            Section(footer: Text("Ghi chú: Khi xóa Nhà xuất bản, liên kết trong sách sẽ được gỡ bỏ an toàn mà không làm mất sách.")) {
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
        // Alert thêm NXB mới
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