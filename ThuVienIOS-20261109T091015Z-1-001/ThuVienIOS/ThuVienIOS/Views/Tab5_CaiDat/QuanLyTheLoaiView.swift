//
//  QuanLyTheLoaiView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.1 - Quản Lý Danh Mục Thể Loại
//  CHỨC NĂNG:
//  - Hiển thị danh sách các thể loại kèm số lượng sách thuộc thể loại đó
//  - Nút (+) mở Alert nhập tên thể loại mới
//  - Thao tác vuốt xóa thể loại an toàn (nullify quan hệ với Sách)
//

import SwiftUI
import SwiftData

struct QuanLyTheLoaiView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Truy vấn danh sách thể loại sắp xếp A-Z
    @Query(sort: \TheLoai.tenTheLoai)
    private var dsTheLoai: [TheLoai]
    
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
            ToolbarItem(placement: .topBarTrailing) {
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
                    modelContext.insert(tl)
                    try? modelContext.save()
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
    
    private func xoaTheLoai(at offsets: IndexSet) {
        for index in offsets {
            let item = dsTheLoai[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}