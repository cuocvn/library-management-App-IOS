//
//  ThemSuaDocGiaView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.2 - Form Thêm Mới hoặc Chỉnh Sửa Độc Giả
//  CHỨC NĂNG:
//  - Nhập thông tin: Họ tên, Số điện thoại, Email, Lớp/Khoa
//  - Phân hạng thành viên: "Thẻ thường" hoặc "🌟 Thẻ Hội viên VIP"
//  - Khởi tạo số dư ví ban đầu nếu là thêm mới
//

import SwiftUI
import SwiftData

struct ThemSuaDocGiaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Độc giả cần sửa (nếu nil là thêm mới)
    var docGiaCanSua: DocGia?
    
    // MARK: - Các trường nhập liệu
    @State private var hoTen: String = ""
    @State private var soDienThoai: String = ""
    @State private var email: String = ""
    @State private var lopKhoa: String = ""
    @State private var loaiThe: String = "Thuong" // "Thuong", "VIP"
    @State private var soDuText: String = "0"
    
    var isEditMode: Bool {
        docGiaCanSua != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Thông tin cá nhân
                Section(header: Text("Thông tin cá nhân")) {
                    TextField("Họ và tên *", text: $hoTen)
                    TextField("Số điện thoại", text: $soDienThoai)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Lớp / Khoa / Đơn vị", text: $lopKhoa)
                }
                
                // Section 2: Hạng thẻ & Số dư ví (Cho phép sửa số tiền bất kỳ lúc nào)
                Section(header: Text("Hạng thẻ & Ví tài khoản"), footer: Text("Quy định: Có nạp tiền vào tài khoản (> 0 đ) tự động là Hội viên VIP (viền vàng, miễn cọc 100%). Không nạp tiền (bằng 0 đ) là Độc giả thường (viền xám). Bạn có thể chỉnh sửa số tiền ví bất cứ lúc nào.")) {
                    HStack {
                        Text("Số dư ví tài khoản:")
                        Spacer()
                        TextField("0", text: $soDuText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.headline)
                            .foregroundColor(AppTheme.primary)
                            .onChange(of: soDuText) { _, newVal in
                                let val = Int(newVal) ?? 0
                                if val > 0 {
                                    loaiThe = "VIP"
                                } else {
                                    loaiThe = "Thuong"
                                }
                            }
                        Text("đ")
                    }
                    
                    Picker("Hạng thẻ", selection: $loaiThe) {
                        Text("Thẻ thường (Viền xám)").tag("Thuong")
                        Text("🌟 Thẻ Hội viên VIP (Viền vàng)").tag("VIP")
                    }
                }
                
                // Ghi chú quyền lợi đặc quyền của Hội viên VIP
                if loaiThe == "VIP" || (Int(soDuText) ?? 0) > 0 {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                            Text("Hội viên VIP (Số dư > 0đ) được miễn 100% tiền cọc khi mượn tất cả các sách!")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? "Sửa Độc Giả" : "Thêm Độc Giả Mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        luuDocGia()
                    }
                    .fontWeight(.bold)
                    .disabled(hoTen.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let dg = docGiaCanSua {
                    hoTen = dg.hoTen
                    soDienThoai = dg.soDienThoai
                    email = dg.email
                    lopKhoa = dg.lopKhoa
                    loaiThe = dg.loaiThe
                    soDuText = String(dg.soDuTaiKhoan)
                }
            }
        }
    }
    
    // MARK: - Hàm lưu độc giả vào SwiftData
    private func luuDocGia() {
        let soDu = max(0, Int(soDuText) ?? 0)
        let hangThe = (soDu > 0) ? "VIP" : loaiThe
        
        if let dg = docGiaCanSua {
            // Cập nhật thông tin độc giả cũ
            dg.hoTen = hoTen
            dg.soDienThoai = soDienThoai
            dg.email = email
            dg.lopKhoa = lopKhoa
            dg.soDuTaiKhoan = soDu
            dg.loaiThe = hangThe
        } else {
            // Thêm độc giả mới hoàn toàn
            let moi = DocGia(
                hoTen: hoTen,
                email: email,
                soDienThoai: soDienThoai,
                lopKhoa: lopKhoa,
                loaiThe: hangThe,
                soDuTaiKhoan: soDu
            )
            modelContext.insert(moi)
        }
        
        try? modelContext.save()
        dismiss()
    }
}