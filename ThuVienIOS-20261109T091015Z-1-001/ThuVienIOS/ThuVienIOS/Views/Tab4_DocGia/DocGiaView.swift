//
//  DocGiaView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct DocGiaView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries
    @Query(filter: #Predicate<DocGia> { !$0.daAn }, sort: \DocGia.hoTen)
    private var dsDocGia: [DocGia]
    
    @State private var searchText: String = ""
    @State private var showingAddSheet: Bool = false
    
    // Tìm kiếm độc giả
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
                ThemSuaDocGiaView()
            }
        }
    }
    
    // Xóa mềm độc giả
    private func xoaDocGia(at offsets: IndexSet) {
        for index in offsets {
            let dg = filteredDocGia[index]
            dg.daAn = true
        }
        try? modelContext.save()
    }
}

// Widget Dòng hiển thị Độc Giả
struct DocGiaRowView: View {
    let docGia: DocGia
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(docGia.isVIP ? Color.orange.opacity(0.15) : AppTheme.primary.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: docGia.isVIP ? "crown.fill" : "person.fill")
                    .font(.title3)
                    .foregroundColor(docGia.isVIP ? .orange : AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(docGia.hoTen)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
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
                
                Text(docGia.lopKhoa.isEmpty ? "Độc giả vãng lai" : docGia.lopKhoa)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 6) {
                    Text("Ví: \(AppTheme.formatVND(docGia.soDuTaiKhoan))")
                        .font(.caption2.bold())
                        .foregroundColor(AppTheme.primary)
                    
                    Text("•")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Đang mượn: \(docGia.soSachDangMuon)")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
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
