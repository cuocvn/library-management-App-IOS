//
//  QuanLyTacGiaView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct QuanLyTacGiaView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \TacGia.tenTacGia)
    private var dsTacGia: [TacGia]
    
    @State private var showingAddAlert: Bool = false
    @State private var tenMoi: String = ""
    
    var body: some View {
        List {
            Section(footer: Text("Ghi chú: Khi xóa Tác giả, sách của tác giả này sẽ chuyển sang trạng thái chưa cập nhật.")) {
                ForEach(dsTacGia, id: \.maTacGia) { tg in
                    HStack {
                        Text(tg.tenTacGia)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(tg.dsSach.count) tác phẩm")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .onDelete(perform: xoaTacGia)
            }
        }
        .navigationTitle("Tác Giả")
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
        .alert("Thêm Tác Giả Mới", isPresented: $showingAddAlert) {
            TextField("Tên tác giả...", text: $tenMoi)
            Button("Thêm") {
                if !tenMoi.trimmingCharacters(in: .whitespaces).isEmpty {
                    let tg = TacGia(tenTacGia: tenMoi.trimmingCharacters(in: .whitespaces))
                    modelContext.insert(tg)
                    try? modelContext.save()
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
    
    private func xoaTacGia(at offsets: IndexSet) {
        for index in offsets {
            let item = dsTacGia[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}
