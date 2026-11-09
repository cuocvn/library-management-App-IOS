//
//  KhoSachView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct KhoSachView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries
    @Query(filter: #Predicate<Sach> { !$0.daAn }, sort: \Sach.tenSach)
    private var danhSachSach: [Sach]
    
    @Query private var dsTheLoai: [TheLoai]
    
    // State tìm kiếm & bộ lọc
    @State private var searchText: String = ""
    @State private var selectedTheLoai: TheLoai?
    @State private var showingAddSheet: Bool = false
    
    // Lọc danh sách theo từ khóa & thể loại
    private var filteredSach: [Sach] {
        danhSachSach.filter { s in
            let matchText = searchText.isEmpty ||
                s.tenSach.localizedCaseInsensitiveContains(searchText) ||
                (s.tacGia?.tenTacGia.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchTheLoai = selectedTheLoai == nil ||
                s.theLoai?.maTheLoai == selectedTheLoai?.maTheLoai
            
            return matchText && matchTheLoai
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Thanh lọc Thể Loại (Pill Filter)
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
                
                // Danh Sách Sách
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ThemSuaSachView()
            }
        }
    }
    
    // Xóa mềm sách (đánh dấu cờ daAn = true)
    private func xoaSach(at offsets: IndexSet) {
        for index in offsets {
            let sach = filteredSach[index]
            sach.daAn = true
        }
        try? modelContext.save()
    }
}

// Subview dòng hiển thị từng cuốn sách
struct SachRowView: View {
    let sach: Sach
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon bìa sách
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 55, height: 75)
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sach.tenSach)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(sach.tacGia?.tenTacGia ?? "Chưa rõ tác giả")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 6) {
                    // Thể loại tag
                    Text(sach.theLoai?.tenTheLoai ?? "Chung")
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Trạng thái tồn kho
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

// Widget Filter Pill
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
