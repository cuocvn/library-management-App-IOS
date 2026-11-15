//
//  DocGiaView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.0 - Quản Lý Độc Giả
//  CHỨC NĂNG:
//  - Tìm kiếm bạn đọc theo Tên, Số điện thoại hoặc Lớp/Khoa
//  - Hiển thị danh sách độc giả với huy hiệu VIP vàng sang trọng
//  - Xem nhanh số dư ví điện tử và số lượng sách đang mượn của từng độc giả
//  - Thao tác vuốt xóa mềm (daAn = true)
//  - Nút (+) mở Sheet 4.2 Thêm Độc Giả mới
//

import SwiftUI

struct DocGiaView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    private var dsDocGia: [DocGia] {
        dataManager.dsDocGia.filter { !$0.daAn }.sorted { $0.hoTen < $1.hoTen }
    }
    
    @State private var searchText: String = ""
    @State private var showingAddSheet: Bool = false
    
    // MARK: - Logic tìm kiếm độc giả
    private var filteredDocGia: [DocGia] {
        if searchText.isEmpty {
            return dsDocGia
        }
        return dsDocGia.filter { dg in
            dg.hoTen.localizedCaseInsensitiveContains(searchText) ||
            dg.soDienThoai.localizedCaseInsensitiveContains(searchText) ||
            dg.lopKhoa.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredDocGia.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "person.slash")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Không tìm thấy độc giả nào")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Nhấn dấu (+) phía trên để thêm độc giả mới")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredDocGia, id: \.maDocGia) { dg in
                            NavigationLink {
                                ChiTietDocGiaView(docGia: dg)
                            } label: {
                                DocGiaRowView(docGia: dg)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: xoaDocGia)
                    }
                    .listStyle(.plain)
                    .background(AppTheme.primaryBackground)
                }
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .navigationTitle("Quản Lý Độc Giả")
            .searchable(text: $searchText, prompt: "Tìm theo tên, SĐT, lớp...")
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
            // Sheet Màn hình 4.2: Thêm độc giả mới
            .sheet(isPresented: $showingAddSheet) {
                ThemSuaDocGiaView()
            }
        }
    }
    
    // MARK: - Xóa mềm độc giả (bảo toàn lịch sử mượn cũ)
    private func xoaDocGia(at offsets: IndexSet) {
        for index in offsets {
            let dg = filteredDocGia[index]
            dg.daAn = true
        }
        dataManager.save()
    }
}

// MARK: - Subview: Dòng hiển thị thông tin độc giả trong List
struct DocGiaRowView: View {
    let docGia: DocGia
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar độc giả: Khác biệt rõ nét qua màu viền avatar
            // - VIP: Viền vàng cam ánh kim 2.5px, icon vương miện
            // - Thường: Viền xám dịu 1.5px, icon người
            ZStack {
                Circle()
                    .fill(docGia.isVIP ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: docGia.isVIP ? "crown.fill" : "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(docGia.isVIP ? .orange : .gray)
                
                Circle()
                    .stroke(docGia.isVIP ? Color.orange : Color.gray.opacity(0.35), lineWidth: docGia.isVIP ? 2.5 : 1.5)
                    .frame(width: 48, height: 48)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(docGia.hoTen)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    // Huy hiệu VIP vàng
                    if docGia.isVIP {
                        Text("VIP")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                // Lớp hoặc đơn vị
                Text(docGia.lopKhoa.isEmpty ? "Độc giả vãng lai" : docGia.lopKhoa)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                // Thẻ số dư ví và số lượng sách đang mượn / nợ sách
                HStack(spacing: 6) {
                    Text("Ví: \(AppTheme.formatVND(docGia.soDuTaiKhoan))")
                        .font(.caption2.bold())
                        .foregroundColor(docGia.isVIP ? .orange : AppTheme.primary)
                    
                    Text("•")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Đang mượn: \(docGia.soSachDangMuon)")
                        .font(.caption2)
                        .foregroundColor(docGia.soSachQuaHan > 0 ? AppTheme.danger : AppTheme.textSecondary)
                    
                    if docGia.soSachQuaHan > 0 {
                        Text("(\(docGia.soSachQuaHan) trễ)")
                            .font(.caption2.bold())
                            .foregroundColor(AppTheme.danger)
                    }
                }
            }
            
            Spacer()
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