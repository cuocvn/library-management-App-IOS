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
    @State private var soDuBanDau: String = "0"
    
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
                
                // Section 2: Hạng thẻ & Số dư ví
                Section(header: Text("Hạng thẻ & Tài khoản")) {
                    Picker("Loại thẻ", selection: $loaiThe) {
                        Text("Thẻ thường").tag("Thuong")
                        Text("🌟 Thẻ Hội viên VIP").tag("VIP")
                    }
                    
                    if !isEditMode {
                        HStack {
                            Text("Số dư nạp ban đầu:")
                            Spacer()
                            TextField("0", text: $soDuBanDau)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("đ")
                        }
                    }
                }
                
                // Ghi chú quyền lợi đặc quyền của Hội viên VIP
                if loaiThe == "VIP" {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                            Text("Hội viên VIP được miễn hoàn toàn tiền cọc khi mượn tất cả các đầu sách!")
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
                }
            }
        }
    }
    
    // MARK: - Hàm lưu độc giả vào SwiftData
    private func luuDocGia() {
        if let dg = docGiaCanSua {
            // Cập nhật thông tin độc giả cũ
            dg.hoTen = hoTen
            dg.soDienThoai = soDienThoai
            dg.email = email
            dg.lopKhoa = lopKhoa
            dg.loaiThe = loaiThe
        } else {
            // Thêm độc giả mới hoàn toàn
            let soDu = Int(soDuBanDau) ?? 0
            let moi = DocGia(
                hoTen: hoTen,
                email: email,
                soDienThoai: soDienThoai,
                lopKhoa: lopKhoa,
                loaiThe: loaiThe,
                soDuTaiKhoan: max(0, soDu)
            )
            modelContext.insert(moi)
        }
        
        try? modelContext.save()
        dismiss()
    }
}