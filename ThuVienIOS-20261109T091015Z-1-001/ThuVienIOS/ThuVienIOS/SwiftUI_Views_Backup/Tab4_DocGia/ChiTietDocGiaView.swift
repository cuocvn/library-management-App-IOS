//
//  ChiTietDocGiaView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.1 - Chi Tiết Độc Giả & Ví Điện Tử Cá Nhân
//  CHỨC NĂNG:
//  - Xem hồ sơ cá nhân: Họ tên, Lớp/Khoa, Hạng thẻ VIP (viền vàng) / Thường (viền xám), SĐT, Email
//  - Quản lý Ví Tài Khoản: Xem số dư hiện tại, có thể sửa trực tiếp hoặc nạp thêm tiền
//  - Lưu vết tài khoản: Nếu độc giả mượn chưa trả hoặc trễ hạn, hệ thống lưu vết cảnh báo đỏ
//  - Nút "Lập Phiếu Mượn Cho Độc Giả Này" -> Nhảy sang 3.1 điền sẵn bạn đọc
//  - Xem danh sách sách độc giả đang giữ và toàn bộ lịch sử giao dịch
//

import SwiftUI

struct ChiTietDocGiaView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    // Đối tượng độc giả được truyền vào
    @ObservedObject var docGia: DocGia
    
    // MARK: - Trạng thái Sheet & Dialog
    @State private var showingEditSheet: Bool = false
    @State private var showingNapTienSheet: Bool = false
    @State private var showingBorrowSheet: Bool = false
    @State private var showingQuickEditBalanceAlert: Bool = false
    @State private var quickBalanceInput: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Card 1 - Thông tin cá nhân & Hạng thẻ
                VStack(spacing: 14) {
                    HStack(spacing: 16) {
                        // Avatar độc giả: Viền vàng cam (VIP) hoặc viền xám (Thường)
                        ZStack {
                            Circle()
                                .fill(docGia.isVIP ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                                .frame(width: 64, height: 64)
                            Image(systemName: docGia.isVIP ? "crown.fill" : "person.fill")
                                .font(.title)
                                .foregroundColor(docGia.isVIP ? .orange : .gray)
                            Circle()
                                .stroke(docGia.isVIP ? Color.orange : Color.gray.opacity(0.35), lineWidth: docGia.isVIP ? 3 : 2)
                                .frame(width: 64, height: 64)
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
                                } else {
                                    Text("Thường")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.15))
                                        .foregroundColor(.gray)
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
                
                // MARK: Cảnh báo Lưu Vết Vi Phạm (Nếu độc giả chưa trả hoặc làm mất sách)
                if docGia.soSachQuaHan > 0 || docGia.soSachBaoMat > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.danger)
                            Text("Lưu Vết Vi Phạm Trên Tài Khoản")
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.danger)
                        }
                        
                        if docGia.soSachQuaHan > 0 {
                            Text("• Độc giả đang giữ \(docGia.soSachQuaHan) cuốn sách đã quá hạn nhưng chưa mang trả!")
                                .font(.caption)
                                .foregroundColor(AppTheme.danger)
                        }
                        
                        if docGia.soSachBaoMat > 0 {
                            Text("• Độc giả có \(docGia.soSachBaoMat) lần báo không trả / làm mất sách (đã bị giam cọc).")
                                .font(.caption)
                                .foregroundColor(AppTheme.danger)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.danger.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.danger.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                // MARK: Card 2 - Thẻ Ví Tài Khoản & Sửa Số Dư / Nạp Tiền
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ví Tài Khoản Nội Bộ")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(AppTheme.formatVND(docGia.soDuTaiKhoan))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(docGia.isVIP ? .orange : AppTheme.primary)
                        }
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Nút Sửa trực tiếp số tiền ví
                            Button {
                                quickBalanceInput = String(docGia.soDuTaiKhoan)
                                showingQuickEditBalanceAlert = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.subheadline.bold())
                                    .padding(8)
                                    .background(Color.gray.opacity(0.15))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .clipShape(Circle())
                            }
                            
                            // Nút mở Sheet nạp tiền vào ví
                            Button {
                                showingNapTienSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Nạp")
                                }
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Text("Ghi chú: Số dư > 0 đ là Hội viên VIP (viền vàng, miễn cọc 100%). Số dư 0 đ là Thường.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text("Sách Đang Giữ Chưa Trả (\(docGia.soSachDangMuon))")
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
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(pm.banSao?.sach?.tenSach ?? "Chưa rõ")
                                        .font(.subheadline.bold())
                                    Text("Mã bản: \(pm.banSao?.maDinhDanh ?? "") • Hạn trả: \(pm.hanTra.formatted(date: .numeric, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(pm.isQuaHan ? AppTheme.danger : AppTheme.textSecondary)
                                    
                                    if let note = pm.ghiChu, !note.isEmpty {
                                        Text("Note: \(note)")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                Spacer()
                                Text(pm.isQuaHan ? "Quá hạn" : "Đang mượn")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(pm.isQuaHan ? AppTheme.danger.opacity(0.12) : AppTheme.primary.opacity(0.12))
                                    .foregroundColor(pm.isQuaHan ? AppTheme.danger : AppTheme.primary)
                                    .cornerRadius(6)
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
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(pm.banSao?.sach?.tenSach ?? "")
                                        .font(.subheadline.weight(.medium))
                                    Text("Mượn: \(pm.ngayMuon.formatted(date: .numeric, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    if let note = pm.ghiChu, !note.isEmpty {
                                        Text(note)
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Text(pm.tinhTrangHienThi)
                                    .font(.caption.bold())
                                    .foregroundColor(pm.daBaoMatSach ? AppTheme.danger : (pm.daTra ? AppTheme.success : (pm.isQuaHan ? AppTheme.danger : AppTheme.primary)))
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sửa") {
                    showingEditSheet = true
                }
            }
        }
        // Sheet sửa thông tin độc giả (bao gồm sửa cả số tiền ví)
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
        // Alert sửa nhanh số dư ví
        .alert("Chỉnh Sửa Số Dư Ví", isPresented: $showingQuickEditBalanceAlert) {
            TextField("Số dư ví (VNĐ)", text: $quickBalanceInput)
                .keyboardType(.numberPad)
            Button("Hủy", role: .cancel) {}
            Button("Cập nhật") {
                let soTienMoi = max(0, Int(quickBalanceInput) ?? 0)
                docGia.soDuTaiKhoan = soTienMoi
                if soTienMoi > 0 {
                    docGia.loaiThe = "VIP"
                }
                dataManager.save()
            }
        } message: {
            Text("Nhập số tiền mới trong ví cho độc giả \(docGia.hoTen). (Nếu > 0 đ tự động hưởng VIP).")
        }
    }
}
