//
//  TraSachView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.2 - Modal Trả Sách, Thu Phạt & Hoàn Cọc
//  CÔNG NGHỆ & ĐIỂM SÁNG ĐỒ ÁN:
//  - Tự động đối soát thời gian: Ngày trả thực tế vs Hạn trả quy định -> Tính số ngày trễ
//  - Tính tiền phạt: Số ngày trễ x Đơn giá phạt (tính theo ngày)
//  - Quyết toán tài chính: Tiền hoàn lại = Tiền cọc - Tiền phạt
//  - Nếu khách bị phạt vượt tiền cọc: Hiển thị cảnh báo số tiền cần nộp thêm
//  - Phương thức hoàn tiền: Tiền mặt hoặc Cộng trực tiếp vào ví độc giả
//  - NẾU KHÁCH KHÔNG TRẢ: Có nút "Báo Không Trả / Mất Sách" -> Giữ lại tiền cọc và lưu vết vi phạm vào tài khoản độc giả!
//  - Cơ chế Snapshot: Lưu cứng tiền phạt và ngày trả vào DB để bảo toàn lịch sử
//

import SwiftUI

struct TraSachView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    
    // Phiếu mượn cần thực hiện quyết toán trả sách
    @ObservedObject var phieuMuon: PhieuMuon
    
    // Đơn giá phạt quá hạn mỗi ngày lấy từ cài đặt hệ thống
    @AppStorage("mucPhatMoiNgay") private var mucPhatMoiNgay: Int = 5000
    
    // MARK: - Trạng thái của Form
    @State private var ngayTraThucTe: Date = Date()
    @State private var phuongThucHoanTien: String = "TaiKhoan" // "TaiKhoan" hoặc "TienMat"
    @State private var showingConfirmMatSachAlert: Bool = false
    
    // MARK: - Logic tính toán số ngày trễ & tiền phạt
    private var soNgayTre: Int {
        let calendar = Calendar.current
        let dTra = calendar.startOfDay(for: ngayTraThucTe)
        let dHan = calendar.startOfDay(for: phieuMuon.hanTra)
        let components = calendar.dateComponents([.day], from: dHan, to: dTra)
        let days = components.day ?? 0
        return max(0, days)
    }
    
    // Tiền phạt quá hạn = Số ngày trễ x Đơn giá phạt mỗi ngày
    private var tienPhat: Int {
        soNgayTre * mucPhatMoiNgay
    }
    
    // Tiền quyết toán = Tiền cọc ban đầu - Tiền phạt
    private var tienQuyetToan: Int {
        phieuMuon.tienCocThucTe - tienPhat
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: 1. Thông tin phiếu mượn & Ghi chú cọc
                Section(header: Text("Thông tin phiếu mượn")) {
                    HStack {
                        Text("Độc giả:")
                        Spacer()
                        Text(phieuMuon.docGia?.hoTen ?? "Chưa rõ")
                            .font(.subheadline.bold())
                    }
                    
                    HStack {
                        Text("Sách mượn:")
                        Spacer()
                        Text(phieuMuon.banSao?.sach?.tenSach ?? "Chưa rõ")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Mã bản sao:")
                        Spacer()
                        Text(phieuMuon.banSao?.maDinhDanh ?? "")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    if let note = phieuMuon.ghiChu, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ghi chú mượn lúc trước:")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(note)
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // MARK: 2. Thời gian đối soát ngày trả & Tính trễ theo ngày
                Section(header: Text("Thời gian đối soát (Phạt tính theo ngày)")) {
                    HStack {
                        Text("Ngày mượn:")
                        Spacer()
                        Text(phieuMuon.ngayMuon.formatted(date: .numeric, time: .omitted))
                    }
                    
                    HStack {
                        Text("Hạn trả quy định:")
                        Spacer()
                        Text(phieuMuon.hanTra.formatted(date: .numeric, time: .omitted))
                            .fontWeight(.semibold)
                    }
                    
                    DatePicker("Ngày trả thực tế:", selection: $ngayTraThucTe, displayedComponents: .date)
                    
                    HStack {
                        Text("Số ngày quá hạn:")
                        Spacer()
                        if soNgayTre > 0 {
                            Text("\(soNgayTre) ngày trễ")
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.danger)
                        } else {
                            Text("Đúng hạn (0 ngày)")
                                .foregroundColor(AppTheme.success)
                        }
                    }
                }
                
                // MARK: 3. Bảng Quyết toán Tài chính Hoàn tiền / Thu phạt
                Section(header: Text("Bảng quyết toán tài chính")) {
                    HStack {
                        Text("Tiền cọc ban đầu (đã thu trước):")
                        Spacer()
                        Text(AppTheme.formatVND(phieuMuon.tienCocThucTe))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Phí phạt trễ hạn (\(soNgayTre) ngày x \(AppTheme.formatVND(mucPhatMoiNgay))/ngày):")
                        Spacer()
                        Text("- \(AppTheme.formatVND(tienPhat))")
                            .foregroundColor(soNgayTre > 0 ? AppTheme.danger : AppTheme.textSecondary)
                    }
                    
                    Divider()
                    
                    // Trường hợp 1: Tiền cọc >= Tiền phạt -> Hoàn tiền lại cho khách
                    if tienQuyetToan >= 0 {
                        HStack {
                            Text("Tổng tiền hoàn lại khách:")
                                .font(.headline)
                            Spacer()
                            Text(AppTheme.formatVND(tienQuyetToan))
                                .font(.headline)
                                .foregroundColor(AppTheme.success)
                        }
                        
                        Picker("Phương thức hoàn tiền cọc thừa", selection: $phuongThucHoanTien) {
                            Text("💳 Cộng lại vào ví").tag("TaiKhoan")
                            Text("💵 Hoàn tiền mặt").tag("TienMat")
                        }
                        .pickerStyle(.segmented)
                    } else {
                        // Trường hợp 2: Tiền phạt > Tiền cọc -> Khách phải nộp thêm tiền
                        HStack {
                            Text("Khách cần nộp phạt thêm:")
                                .font(.headline)
                            Spacer()
                            Text(AppTheme.formatVND(abs(tienQuyetToan)))
                                .font(.headline)
                                .foregroundColor(AppTheme.danger)
                        }
                    }
                }
                
                // MARK: 4. Xử Lý Khách Không Trả Sách / Làm Mất Sách
                Section(header: Text("Xử lý sự cố không trả sách"), footer: Text("Nếu bạn đọc làm mất hoặc không trả sách, thư viện sẽ giữ lại toàn bộ số tiền cọc đã thu và lưu vết vi phạm vào hồ sơ tài khoản của độc giả.")) {
                    Button(role: .destructive) {
                        showingConfirmMatSachAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill")
                            Text("Báo Khách Không Trả Sách / Làm Mất Sách")
                        }
                        .foregroundColor(AppTheme.danger)
                    }
                }
            }
            .navigationTitle("Trả Sách & Thu Phạt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xác Nhận Trả") {
                        thucHienTraSach()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Xác Nhận Khách Không Trả Sách?", isPresented: $showingConfirmMatSachAlert) {
                Button("Hủy", role: .cancel) {}
                Button("Xác Nhận (Giữ Cọc & Lưu Vết)", role: .destructive) {
                    thucHienBaoMatSach()
                }
            } message: {
                Text("Hệ thống sẽ giữ lại toàn bộ số tiền cọc (\(AppTheme.formatVND(phieuMuon.tienCocThucTe))), đánh dấu sách bị hư hỏng/thất lạc, và lưu vết vi phạm vào hồ sơ tài khoản của độc giả \(phieuMuon.docGia?.hoTen ?? "").")
            }
        }
    }
    
    // MARK: - Hàm thực hiện trả sách bình thường
    private func thucHienTraSach() {
        guard phieuMuon.ngayTra == nil else { return }
        
        phieuMuon.ngayTra = ngayTraThucTe
        phieuMuon.soNgayTre = soNgayTre
        phieuMuon.tienPhat = tienPhat
        phieuMuon.phuongThucHoanTien = phuongThucHoanTien
        
        // Xử lý hoàn tiền cọc thừa nếu hoàn vào ví
        if let dg = phieuMuon.docGia {
            if tienQuyetToan > 0 && phuongThucHoanTien == "TaiKhoan" {
                dg.soDuTaiKhoan += tienQuyetToan
            } else if tienQuyetToan < 0 && phuongThucHoanTien == "TaiKhoan" {
                dg.soDuTaiKhoan += tienQuyetToan
            }
        }
        
        // Trả tình trạng cuốn sách vật lý về lại "SanSang"
        phieuMuon.banSao?.tinhTrang = "SanSang"
        
        dataManager.save()
        dismiss()
    }
    
    // MARK: - Hàm xử lý khi khách KHÔNG TRẢ SÁCH (Báo mất sách)
    private func thucHienBaoMatSach() {
        guard phieuMuon.ngayTra == nil else { return }
        
        phieuMuon.ngayTra = Date()
        phieuMuon.daBaoMatSach = true
        phieuMuon.ghiChu = (phieuMuon.ghiChu ?? "") + " [BÁO MẤT: Khách không trả sách, thư viện giữ toàn bộ cọc \(AppTheme.formatVND(phieuMuon.tienCocThucTe))]"
        
        // Chuyển bản sao vật lý sang trạng thái "Hong" (thất lạc / hư hại)
        phieuMuon.banSao?.tinhTrang = "Hong"
        
        // Toàn bộ tiền cọc bị giữ lại, không hoàn trả
        phieuMuon.soNgayTre = soNgayTre
        phieuMuon.tienPhat = 0
        
        dataManager.save()
        dismiss()
    }
}
