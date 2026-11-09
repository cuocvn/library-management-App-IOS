//
//  TraSachView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.2 - Modal Trả Sách, Thu Phạt & Hoàn Cọc
//  CÔNG NGHỆ & ĐIỂM SÁNG ĐỒ ÁN:
//  - Tự động đối soát thời gian: Ngày trả thực tế vs Hạn trả quy định -> Tính số ngày trễ
//  - Tính tiền phạt: Số ngày trễ x Đơn giá phạt (lấy từ cài đặt @AppStorage)
//  - Quyết toán tài chính: Tiền hoàn lại = Tiền cọc - Tiền phạt
//  - Nếu khách bị phạt vượt tiền cọc: Hiển thị cảnh báo số tiền cần nộp thêm
//  - Phương thức hoàn tiền: Tiền mặt hoặc Cộng trực tiếp vào ví độc giả
//  - Cơ chế Snapshot: Lưu cứng tiền phạt và ngày trả vào DB để bảo toàn lịch sử
//  - Trả trạng thái bản sao sách về lại "SanSang"
//

import SwiftUI
import SwiftData

struct TraSachView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Phiếu mượn cần thực hiện quyết toán trả sách
    @Bindable var phieuMuon: PhieuMuon
    
    // Đơn giá phạt quá hạn mỗi ngày lấy từ cài đặt hệ thống
    @AppStorage("mucPhatMoiNgay") private var mucPhatMoiNgay: Int = 5000
    
    // MARK: - Trạng thái của Form
    @State private var ngayTraThucTe: Date = Date()
    @State private var phuongThucHoanTien: String = "TaiKhoan" // "TaiKhoan" hoặc "TienMat"
    @State private var showingSuccessAlert: Bool = false
    
    // MARK: - Logic tính toán số ngày trễ & tiền phạt
    // Số ngày trễ = max(0, Ngày trả thực tế - Hạn trả)
    private var soNgayTre: Int {
        let calendar = Calendar.current
        let dTra = calendar.startOfDay(for: ngayTraThucTe)
        let dHan = calendar.startOfDay(for: phieuMuon.hanTra)
        let components = calendar.dateComponents([.day], from: dHan, to: dTra)
        let days = components.day ?? 0
        return max(0, days)
    }
    
    // Tiền phạt quá hạn = Số ngày trễ x Đơn giá phạt
    private var tienPhat: Int {
        soNgayTre * mucPhatMoiNgay
    }
    
    // Tiền quyết toán = Tiền cọc ban đầu - Tiền phạt
    // (Nếu dương: thư viện hoàn trả cho khách; Nếu âm: khách phải nộp thêm tiền phạt)
    private var tienQuyetToan: Int {
        phieuMuon.tienCocThucTe - tienPhat
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: 1. Thông tin phiếu mượn
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
                }
                
                // MARK: 2. Thời gian đối soát ngày trả
                Section(header: Text("Thời gian đối soát")) {
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
                    
                    // Người dùng có thể chọn ngày trả thực tế để test kịch bản trễ hạn
                    DatePicker("Ngày trả thực tế:", selection: $ngayTraThucTe, displayedComponents: .date)
                    
                    HStack {
                        Text("Số ngày quá hạn:")
                        Spacer()
                        if soNgayTre > 0 {
                            Text("\(soNgayTre) ngày")
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
                        Text("Tiền cọc ban đầu:")
                        Spacer()
                        Text(AppTheme.formatVND(phieuMuon.tienCocThucTe))
                    }
                    
                    HStack {
                        Text("Phí phạt quá hạn (\(soNgayTre) ngày):")
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
                        
                        Picker("Phương thức hoàn tiền", selection: $phuongThucHoanTien) {
                            Text("💳 Cộng vào ví").tag("TaiKhoan")
                            Text("💵 Tiền mặt").tag("TienMat")
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
        }
    }
    
    // MARK: - Hàm thực hiện trả sách & ghi Snapshot bất biến
    private func thucHienTraSach() {
        // 1. Chặn trả 2 lần nếu phiếu đã được trả rồi
        guard phieuMuon.ngayTra == nil else { return }
        
        // 2. Ghi Snapshot tài chính cố định vào Database (bất biến sau này)
        phieuMuon.ngayTra = ngayTraThucTe
        phieuMuon.soNgayTre = soNgayTre
        phieuMuon.tienPhat = tienPhat
        phieuMuon.phuongThucHoanTien = phuongThucHoanTien
        
        // 3. Xử lý hoàn tiền / cộng ví độc giả nếu chọn "TaiKhoan"
        if let dg = phieuMuon.docGia {
            if tienQuyetToan > 0 && phuongThucHoanTien == "TaiKhoan" {
                // Hoàn lại tiền cọc thừa vào ví
                dg.soDuTaiKhoan += tienQuyetToan
            } else if tienQuyetToan < 0 && phuongThucHoanTien == "TaiKhoan" {
                // Trừ thêm nếu bị phạt vượt cọc
                dg.soDuTaiKhoan += tienQuyetToan
            }
        }
        
        // 4. Trả tình trạng cuốn sách vật lý về lại "SanSang" để người khác có thể mượn tiếp
        phieuMuon.banSao?.tinhTrang = "SanSang"
        
        try? modelContext.save()
        dismiss()
    }
}