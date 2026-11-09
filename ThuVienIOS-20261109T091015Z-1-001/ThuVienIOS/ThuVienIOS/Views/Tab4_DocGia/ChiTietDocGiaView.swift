//
//  ChiTietDocGiaView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.1 - Chi Tiết Độc Giả & Ví Điện Tử Cá Nhân
//  CHỨC NĂNG:
//  - Xem hồ sơ cá nhân: Họ tên, Lớp/Khoa, Hạng thẻ VIP, SĐT, Email
//  - Quản lý Ví Tài Khoản: Xem số dư hiện tại, nút mở Sheet 4.1.1 "Nạp Tiền"
//  - Nút "Lập Phiếu Mượn Cho Độc Giả Này" -> Nhảy sang 3.1 điền sẵn bạn đọc
//  - Xem danh sách sách độc giả đang giữ (cảnh báo đỏ nếu trễ hạn)
//  - Xem toàn bộ lịch sử các lần mượn/trả trong quá khứ của độc giả này
//

import SwiftUI
import SwiftData

struct ChiTietDocGiaView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Đối tượng độc giả được truyền vào
    @Bindable var docGia: DocGia
    
    // MARK: - Trạng thái Sheet
    @State private var showingEditSheet: Bool = false
    @State private var showingNapTienSheet: Bool = false
    @State private var showingBorrowSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Card 1 - Thông tin cá nhân & Hạng thẻ
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
                
                // MARK: Card 2 - Thẻ Ví Tài Khoản & Nút Nạp Tiền
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
                        
                        // Nút mở Sheet nạp tiền vào ví
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
                
                // MARK: Nút Hành Động - Lập Phiếu Mượn Cho Độc Giả Này
                Button {
                    showingBorrowSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.rectangle.on.rectangle")
                            .font(.headline)
                        Text("Lập Phiếu Mượn Cho Độc Giả Này")
                            .font(.headline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, y: 3)
                }
                .padding(.horizontal)
                
                // MARK: Card 3 - Danh sách Sách Đang Mượn
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
                
                // MARK: Card 4 - Toàn Bộ Lịch Sử Giao Dịch
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
        // Sheet sửa thông tin độc giả
        .sheet(isPresented: $showingEditSheet) {
            ThemSuaDocGiaView(docGiaCanSua: docGia)
        }
        // Sheet nạp tiền vào ví
        .sheet(isPresented: $showingNapTienSheet) {
            NapTienView(docGia: docGia)
        }
        // Sheet tạo phiếu mượn cho độc giả này
        .sheet(isPresented: $showingBorrowSheet) {
            TaoPhieuMuonView(docGiaBanDau: docGia)
        }
    }
}