//
//  KhoSachView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 2.0 - Quản lý Kho Sách
//  CHỨC NĂNG:
//  - Tìm kiếm sách theo tên hoặc tác giả (searchable)
//  - Bộ lọc nhanh theo Thể loại (Pill Filter cuộn ngang)
//  - Hiển thị danh sách sách với huy hiệu tồn kho bản sao vật lý ("Còn X/Y cuốn")
//  - Thao tác vuốt xóa mềm sách (daAn = true)
//  - Nút (+) mở Sheet thêm sách mới
//

import SwiftUI

struct KhoSachView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    private var danhSachSach: [Sach] {
        dataManager.dsSach.filter { !$0.daAn }.sorted { $0.tenSach < $1.tenSach }
    }
    
    private var dsTheLoai: [TheLoai] {
        dataManager.dsTheLoai
    }
    
    // MARK: - Các biến trạng thái giao diện (UI State)
    @State private var searchText: String = ""
    @State private var selectedTheLoai: TheLoai?
    @State private var showingAddSheet: Bool = false
    
    // MARK: - Logic lọc danh sách theo từ khóa & thể loại
    private var filteredSach: [Sach] {
        danhSachSach.filter { s in
            // Điều kiện 1: Khớp từ khóa tìm kiếm (tên sách hoặc tên tác giả)
            let matchText = searchText.isEmpty ||
                s.tenSach.localizedCaseInsensitiveContains(searchText) ||
                (s.tacGia?.tenTacGia.localizedCaseInsensitiveContains(searchText) ?? false)
            
            // Điều kiện 2: Khớp thể loại đang chọn (nếu chọn "Tất cả" thì selectedTheLoai == nil)
            let matchTheLoai = selectedTheLoai == nil ||
                s.theLoai?.maTheLoai == selectedTheLoai?.maTheLoai
            
            return matchText && matchTheLoai
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: 1. Thanh lọc Thể Loại (Pill Filter cuộn ngang)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(
                            title: "Tất cả",
                            isSelected: selectedTheLoai == nil
                        ) {
                            selectedTheLoai = nil
                        }
                        
                        ForEach(dsTheLoai, id: \.maTheLoai) { tl in
                            FilterPill(
                                title: tl.tenTheLoai,
                                isSelected: selectedTheLoai?.maTheLoai == tl.maTheLoai
                            ) {
                                selectedTheLoai = tl
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(AppTheme.cardBackground)
                
                Divider()
                
                // MARK: 2. Danh Sách Sách Hiển Thị
                if filteredSach.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Không tìm thấy đầu sách nào")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Thử thay đổi từ khóa hoặc bộ lọc thể loại")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredSach, id: \.maSach) { sach in
                            NavigationLink {
                                ChiTietSachView(sach: sach)
                            } label: {
                                SachRowView(sach: sach)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: xoaSach)
                    }
                    .listStyle(.plain)
                    .background(AppTheme.primaryBackground)
                }
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .navigationTitle("Kho Sách")
            .searchable(text: $searchText, prompt: "Tìm theo tên sách, tác giả...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            // Sheet mở form thêm sách mới
            .sheet(isPresented: $showingAddSheet) {
                ThemSuaSachView()
            }
        }
    }
    
    // MARK: - Hàm xóa mềm sách (đánh dấu cờ daAn = true để bảo toàn lịch sử mượn cũ)
    private func xoaSach(at offsets: IndexSet) {
        for index in offsets {
            let sach = filteredSach[index]
            sach.daAn = true
        }
        dataManager.save()
    }
}

// MARK: - Subview: Dòng hiển thị từng cuốn sách trong List
struct SachRowView: View {
    let sach: Sach
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon bìa sách tượng trưng
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 55, height: 75)
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Tên đầu sách
                Text(sach.tenSach)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                // Tác giả
                Text(sach.tacGia?.tenTacGia ?? "Chưa rõ tác giả")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 6) {
                    // Nhãn thể loại nhỏ
                    Text(sach.theLoai?.tenTheLoai ?? "Chung")
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Tình trạng tồn kho bản sao: Xanh nếu còn sách, Đỏ nếu đã hết
                    HStack(spacing: 3) {
                        Circle()
                            .fill(sach.soLuongKhaDung > 0 ? AppTheme.success : AppTheme.danger)
                            .frame(width: 6, height: 6)
                        Text("Còn \(sach.soLuongKhaDung)/\(sach.tongSoBanSao)")
                            .font(.caption2.bold())
                            .foregroundColor(sach.soLuongKhaDung > 0 ? AppTheme.success : AppTheme.danger)
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }
}

// MARK: - Widget Filter Pill (Nút bấm dạng viên thuốc bo tròn để lọc thể loại)
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.primary : AppTheme.primaryBackground)
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                .cornerRadius(20)
        }
    }
}