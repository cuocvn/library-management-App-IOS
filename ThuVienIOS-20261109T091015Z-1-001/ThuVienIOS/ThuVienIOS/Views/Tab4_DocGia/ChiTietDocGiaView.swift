//
//  ChiTietDocGiaView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct ChiTietDocGiaView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var docGia: DocGia
    
    @State private var showingEditSheet: Bool = false
    @State private var showingNapTienSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Card 1: Thông tin cá nhân & Hạng thẻ
                VStack(spacing: 14) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(docGia.isVIP ? Color.orange.opacity(0.15) : AppTheme.primary.opacity(0.12))
                                .frame(width: 64, height: 64)
                            Image(systemName: docGia.isVIP ? "crown.fill" : "person.fill")
                                .font(.title)
                                .foregroundColor(docGia.isVIP ? .orange : AppTheme.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(docGia.hoTen)
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                if docGia.isVIP {
                                    Text("VIP")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text(docGia.lopKhoa.isEmpty ? "Độc giả vãng lai" : docGia.lopKhoa)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Thông tin liên hệ
                    VStack(spacing: 8) {
                        HStack {
                            Label(docGia.soDienThoai.isEmpty ? "Chưa có SĐT" : docGia.soDienThoai, systemImage: "phone.fill")
                                .font(.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                        }
                        HStack {
                            Label(docGia.email.isEmpty ? "Chưa có email" : docGia.email, systemImage: "envelope.fill")
                                .font(.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Card 2: Thẻ Ví Tài Khoản & Nạp Tiền
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ví Tài Khoản")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(AppTheme.formatVND(docGia.soDuTaiKhoan))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.primary)
                        }
                        Spacer()
                        
                        Button {
                            showingNapTienSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Nạp Tiền")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Card 3: Sách Đang Mượn
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sách Đang Mượn (\(docGia.soSachDangMuon))")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    let dangMuon = docGia.dsPhieuMuon.filter { $0.ngayTra == nil }
                    if dangMuon.isEmpty {
                        Text("Độc giả hiện không giữ cuốn sách nào.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(dangMuon, id: \.maPhieu) { pm in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pm.banSao?.sach?.tenSach ?? "Chưa rõ")
                                        .font(.subheadline.bold())
                                    Text("Bản: \(pm.banSao?.maDinhDanh ?? "") • Hạn: \(pm.hanTra.formatted(date: .numeric, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(pm.isQuaHan ? AppTheme.danger : AppTheme.textSecondary)
                                }
                                Spacer()
                                Text(pm.isQuaHan ? "Quá hạn" : "Đang giữ")
                                    .font(.caption.bold())
                                    .foregroundColor(pm.isQuaHan ? AppTheme.danger : AppTheme.primary)
                            }
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Card 4: Lịch Sử Mượn Cá Nhân
                VStack(alignment: .leading, spacing: 12) {
                    Text("Toàn Bộ Lịch Sử Giao Dịch")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if docGia.dsPhieuMuon.isEmpty {
                        Text("Chưa có lịch sử giao dịch nào.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    } else {
                        ForEach(docGia.dsPhieuMuon, id: \.maPhieu) { pm in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pm.banSao?.sach?.tenSach ?? "")
                                        .font(.subheadline.weight(.medium))
                                    Text("Ngày mượn: \(pm.ngayMuon.formatted(date: .numeric, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                Text(pm.tinhTrangHienThi)
                                    .font(.caption.bold())
                                    .foregroundColor(pm.daTra ? AppTheme.success : (pm.isQuaHan ? AppTheme.danger : AppTheme.primary))
                            }
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .navigationTitle("Hồ Sơ Độc Giả")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sửa") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ThemSuaDocGiaView(docGiaCanSua: docGia)
        }
        .sheet(isPresented: $showingNapTienSheet) {
            NapTienView(docGia: docGia)
        }
    }
}
