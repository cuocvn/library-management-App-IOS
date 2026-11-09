//
//  MuonTraView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct MuonTraView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries
    @Query(sort: \PhieuMuon.ngayMuon, order: .reverse)
    private var danhSachPhieu: [PhieuMuon]
    
    // Trạng thái lọc Tab con
    @State private var filterStatus: String = "DangMuon" // "DangMuon", "QuaHan", "DaTra", "TatCa"
    @State private var showingCreateSheet: Bool = false
    @State private var phieuCanTra: PhieuMuon?
    
    // Lọc danh sách theo Tab
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
                // Segmented Control lọc trạng thái
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
                
                // Danh sách các phiếu mượn
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
                                phieuCanTra = pm
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                TaoPhieuMuonView()
            }
            .sheet(item: $phieuCanTra) { pm in
                TraSachView(phieuMuon: pm)
            }
        }
    }
}

// Widget Dòng hiển thị Phiếu Mượn
struct PhieuMuonRowView: View {
    let phieuMuon: PhieuMuon
    let onTraSach: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(phieuMuon.banSao?.sach?.tenSach ?? "Chưa rõ sách")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
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
                
                // Badge trạng thái
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
                    Text("Hạn trả: \(phieuMuon.hanTra.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(phieuMuon.isQuaHan && !phieuMuon.daTra ? AppTheme.danger : AppTheme.textSecondary)
                    
                    if let dTra = phieuMuon.ngayTra {
                        Text("Đã trả ngày: \(dTra.formatted(date: .numeric, time: .omitted))")
                            .font(.caption2)
                            .foregroundColor(AppTheme.success)
                    }
                }
                
                Spacer()
                
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
