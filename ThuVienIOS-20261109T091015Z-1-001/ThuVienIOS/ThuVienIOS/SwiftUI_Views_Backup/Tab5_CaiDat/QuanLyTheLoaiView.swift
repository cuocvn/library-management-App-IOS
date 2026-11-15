//
//  QuanLyTheLoaiView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.1 - Quản Lý Danh Mục Thể Loại
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import SwiftUI

struct QuanLyTheLoaiView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    private var dsTheLoai: [TheLoai] {
        dataManager.dsTheLoai.sorted { $0.tenTheLoai < $1.tenTheLoai }
    }
    
    @State private var showingAddAlert: Bool = false
    @State private var tenMoi: String = ""
    
    var body: some View {
        List {
            Section(footer: Text("Ghi chú: Khi xóa thể loại, các sách thuộc thể loại này sẽ được giữ lại an toàn và chuyển về nhóm chung.")) {
                ForEach(dsTheLoai, id: \.maTheLoai) { tl in
                    HStack {
                        Text(tl.tenTheLoai)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(tl.dsSach.count) sách")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .onDelete(perform: xoaTheLoai)
            }
        }
        .navigationTitle("Quản Lý Thể Loại")
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
        // Alert thêm thể loại mới
        .alert("Thêm Thể Loại Mới", isPresented: $showingAddAlert) {
            TextField("Tên thể loại...", text: $tenMoi)
            Button("Thêm") {
                if !tenMoi.trimmingCharacters(in: .whitespaces).isEmpty {
                    let tl = TheLoai(tenTheLoai: tenMoi.trimmingCharacters(in: .whitespaces))
                    dataManager.themTheLoai(tl)
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
    
    private func xoaTheLoai(at offsets: IndexSet) {
        for index in offsets {
            let item = dsTheLoai[index]
            dataManager.xoaTheLoai(item)
        }
    }
}
