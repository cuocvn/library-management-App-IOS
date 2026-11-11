//
//  QuanLyNXBView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.2 - Quản Lý Danh Mục Nhà Xuất Bản
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import SwiftUI

struct QuanLyNXBView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    private var dsNXB: [NhaXuatBan] {
        dataManager.dsNXB.sorted { $0.tenNXB < $1.tenNXB }
    }
    
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
            ToolbarItem(placement: .navigationBarTrailing) {
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
                    dataManager.themNXB(nxb)
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
    
    private func xoaNXB(at offsets: IndexSet) {
        for index in offsets {
            let item = dsNXB[index]
            dataManager.xoaNXB(item)
        }
    }
}
