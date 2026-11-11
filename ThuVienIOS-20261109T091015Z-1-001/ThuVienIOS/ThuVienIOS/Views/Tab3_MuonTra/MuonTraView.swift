//
//  MuonTraView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.0 - Quản Lý Mượn & Trả Sách
//  CHỨC NĂNG:
//  - Lọc phiếu mượn theo 4 trạng thái qua Segmented Control:
//    1. "Đang mượn": Sách đang được mượn và chưa đến hạn trả
//    2. "Quá hạn": Sách đang mượn nhưng đã trễ hạn quy định (cảnh báo đỏ)
//    3. "Đã trả": Các phiếu đã hoàn tất trả sách trong quá khứ
//    4. "Tất cả": Xem toàn bộ giao dịch
//  - Thao tác vuốt (Swipe) để trả sách nhanh
//  - Nút (+) mở Sheet 3.1 Tạo Phiếu Mượn mới
//  - Bấm nút "Trả sách" mở Sheet 3.2 Quyết toán & Thu phạt
//

import SwiftUI

struct MuonTraView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    private var danhSachPhieu: [PhieuMuon] {
        dataManager.dsPhieuMuon.sorted { $0.ngayMuon > $1.ngayMuon }
    }
    
    // MARK: - Trạng thái lọc Tab con
    @State private var filterStatus: String = "DangMuon" // "DangMuon", "QuaHan", "DaTra", "TatCa"
    @State private var showingCreateSheet: Bool = false
    @State private var phieuCanTra: PhieuMuon?
    
    // MARK: - Logic lọc phiếu mượn theo Segmented Control
    private var filteredPhieu: [PhieuMuon] {
        danhSachPhieu.filter { pm in
            switch filterStatus {
            case "DangMuon":
                return pm.ngayTra == nil && !pm.isQuaHan
            case "QuaHan":
                return pm.ngayTra == nil && pm.isQuaHan
            case "DaTra":
                return pm.ngayTra != nil
            default: // TatCa
                return true
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: 1. Thanh lọc phân loại trạng thái (Segmented Control)
                Picker("Trạng thái", selection: $filterStatus) {
                    Text("Đang mượn").tag("DangMuon")
                    Text("Quá hạn").tag("QuaHan")
                    Text("Đã trả").tag("DaTra")
                    Text("Tất cả").tag("TatCa")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(AppTheme.cardBackground)
                
                Divider()
                
                // MARK: 2. Danh sách Phiếu Mượn
                if filteredPhieu.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Không có phiếu mượn nào trong mục này")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredPhieu, id: \.maPhieu) { pm in
                            PhieuMuonRowView(phieuMuon: pm) {
                                // Mở modal trả sách khi bấm nút
                                phieuCanTra = pm
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            // Hỗ trợ vuốt sang trái để trả sách nhanh
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if pm.ngayTra == nil {
                                    Button {
                                        phieuCanTra = pm
                                    } label: {
                                        Label("Trả sách", systemImage: "arrow.uturn.backward.circle.fill")
                                    }
                                    .tint(AppTheme.success)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(AppTheme.primaryBackground)
                }
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .navigationTitle("Mượn & Trả Sách")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            // Sheet Màn hình 3.1: Tạo Phiếu Mượn
            .sheet(isPresented: $showingCreateSheet) {
                TaoPhieuMuonView()
            }
            // Sheet Màn hình 3.2: Trả Sách & Thu Phạt
            .sheet(item: $phieuCanTra) { pm in
                TraSachView(phieuMuon: pm)
            }
        }
    }
}

// MARK: - Subview: Thẻ hiển thị từng Phiếu Mượn
struct PhieuMuonRowView: View {
    let phieuMuon: PhieuMuon
    let onTraSach: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    // Tên cuốn sách
                    Text(phieuMuon.banSao?.sach?.tenSach ?? "Chưa rõ sách")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    // Mã bản sao & Tên người mượn
                    HStack(spacing: 6) {
                        Text("Mã bản: \(phieuMuon.banSao?.maDinhDanh ?? "")")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.primary)
                        
                        Text("•")
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(phieuMuon.docGia?.hoTen ?? "Chưa rõ độc giả")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Badge trạng thái: Đã trả (xanh lá), Quá hạn (đỏ), Đang mượn (xanh dương)
                Text(phieuMuon.tinhTrangHienThi)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        phieuMuon.daTra ? AppTheme.success.opacity(0.12) :
                            (phieuMuon.isQuaHan ? AppTheme.danger.opacity(0.12) : AppTheme.primary.opacity(0.12))
                    )
                    .foregroundColor(
                        phieuMuon.daTra ? AppTheme.success :
                            (phieuMuon.isQuaHan ? AppTheme.danger : AppTheme.primary)
                    )
                    .cornerRadius(6)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    // Hiển thị hạn trả
                    Text("Hạn trả: \(phieuMuon.hanTra.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(phieuMuon.isQuaHan && !phieuMuon.daTra ? AppTheme.danger : AppTheme.textSecondary)
                    
                    // Nếu đã trả thì hiển thị ngày trả
                    if let dTra = phieuMuon.ngayTra {
                        Text("Đã trả ngày: \(dTra.formatted(date: .numeric, time: .omitted))")
                            .font(.caption2)
                            .foregroundColor(AppTheme.success)
                    }
                }
                
                Spacer()
                
                // Nếu chưa trả: hiển thị nút "Trả sách"
                if phieuMuon.ngayTra == nil {
                    Button(action: onTraSach) {
                        Text("Trả sách")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else if let phat = phieuMuon.tienPhat, phat > 0 {
                    // Nếu đã trả và có tiền phạt thì hiển thị số tiền phạt
                    Text("Phạt: \(AppTheme.formatVND(phat))")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.danger)
                }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }
}