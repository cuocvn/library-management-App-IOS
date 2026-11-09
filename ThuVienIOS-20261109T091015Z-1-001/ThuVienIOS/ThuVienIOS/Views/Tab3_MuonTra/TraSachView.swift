//
//  TraSachView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct TraSachView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var phieuMuon: PhieuMuon
    
    // Đơn giá phạt từ AppStorage
    @AppStorage("mucPhatMoiNgay") private var mucPhatMoiNgay: Int = 5000
    
    @State private var ngayTraThucTe: Date = Date()
    @State private var phuongThucHoanTien: String = "TaiKhoan" // "TaiKhoan" hoặc "TienMat"
    @State private var showingSuccessAlert: Bool = false
    
    // Tính toán số ngày trễ & phạt
    private var soNgayTre: Int {
        let calendar = Calendar.current
        let dTra = calendar.startOfDay(for: ngayTraThucTe)
        let dHan = calendar.startOfDay(for: phieuMuon.hanTra)
        let components = calendar.dateComponents([.day], from: dHan, to: dTra)
        let days = components.day ?? 0
        return max(0, days)
    }
    
    private var tienPhat: Int {
        soNgayTre * mucPhatMoiNgay
    }
    
    // Đối soát tài chính: Tiền hoàn = Tiền cọc - Tiền phạt
    private var tienQuyetToan: Int {
        phieuMuon.tienCocThucTe - tienPhat
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Thông tin phiếu
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
                
                // Section 2: Thời hạn & Đối soát ngày trả
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
                
                // Section 3: Bảng Quyết toán Hoàn tiền / Thu phạt
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
                        // Khách phạt vượt quá tiền cọc -> Cần nộp thêm
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
    
    // Nghiệp vụ cốt lõi Trả sách & Snapshot tài chính bất biến
    private func thucHienTraSach() {
        // 1. Chặn trả 2 lần
        guard phieuMuon.ngayTra == nil else { return }
        
        // 2. Ghi snapshot bất biến vào Database
        phieuMuon.ngayTra = ngayTraThucTe
        phieuMuon.soNgayTre = soNgayTre
        phieuMuon.tienPhat = tienPhat
        phieuMuon.phuongThucHoanTien = phuongThucHoanTien
        
        // 3. Hoàn tiền nếu có
        if let dg = phieuMuon.docGia {
            if tienQuyetToan > 0 && phuongThucHoanTien == "TaiKhoan" {
                dg.soDuTaiKhoan += tienQuyetToan
            } else if tienQuyetToan < 0 && phuongThucHoanTien == "TaiKhoan" {
                // Trừ thêm nếu chọn ví
                dg.soDuTaiKhoan += tienQuyetToan // tienQuyetToan âm -> tự trừ
            }
        }
        
        // 4. Trả trạng thái bản sao sách về "SanSang"
        phieuMuon.banSao?.tinhTrang = "SanSang"
        
        try? modelContext.save()
        dismiss()
    }
}
