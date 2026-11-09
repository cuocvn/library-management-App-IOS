//
//  DocGia.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Bạn Đọc / Độc Giả của Thư viện
//  TÍNH NĂNG ĐẶC BIỆT: Hỗ trợ Ví điện tử nội bộ (soDuTaiKhoan) và Hạng Hội viên VIP (loaiThe)
//

import Foundation
import SwiftData

@Model
final class DocGia {
    // Mã độc giả duy nhất
    @Attribute(.unique) var maDocGia: UUID
    
    // Họ và tên độc giả (VD: "Trần Quốc Bảo")
    var hoTen: String
    
    // Địa chỉ email liên hệ
    var email: String
    
    // Số điện thoại
    var soDienThoai: String
    
    // Lớp / Khoa / Đơn vị công tác (VD: "CNTT K20")
    var lopKhoa: String
    
    // Hạng thẻ độc giả:
    // - "Thuong": Độc giả thông thường, tính tiền cọc theo quy định
    // - "VIP": Hội viên VIP, được đặc quyền MIỄN 100% TIỀN CỌC khi mượn sách
    var loaiThe: String
    
    // Số dư ví điện tử nội bộ của độc giả (đơn vị: VNĐ)
    // Độc giả có thể nạp tiền vào ví để trừ tiền mượn sách hoặc nhận tiền hoàn cọc
    var soDuTaiKhoan: Int
    
    // Cờ xóa mềm (true: đã ẩn khỏi danh sách)
    var daAn: Bool
    
    // Danh sách toàn bộ các phiếu mượn của độc giả này
    @Relationship(deleteRule: .cascade, inverse: \PhieuMuon.docGia)
    var dsPhieuMuon: [PhieuMuon] = []
    
    // Hàm khởi tạo
    init(
        maDocGia: UUID = UUID(),
        hoTen: String,
        email: String = "",
        soDienThoai: String = "",
        lopKhoa: String = "",
        loaiThe: String = "Thuong",
        soDuTaiKhoan: Int = 0,
        daAn: Bool = false
    ) {
        self.maDocGia = maDocGia
        self.hoTen = hoTen
        self.email = email
        self.soDienThoai = soDienThoai
        self.lopKhoa = lopKhoa
        self.loaiThe = loaiThe
        self.soDuTaiKhoan = soDuTaiKhoan
        self.daAn = daAn
    }
    
    // MARK: - Thuộc tính tiện ích
    
    // Đếm số cuốn sách hiện tại độc giả đang mượn về (phiếu chưa trả)
    var soSachDangMuon: Int {
        dsPhieuMuon.filter { $0.ngayTra == nil }.count
    }
    
    // Đếm số sách bị trễ hạn chưa trả
    var soSachQuaHan: Int {
        dsPhieuMuon.filter { $0.ngayTra == nil && $0.isQuaHan }.count
    }
    
    // Đếm số sách báo không trả / làm mất
    var soSachBaoMat: Int {
        dsPhieuMuon.filter { $0.daBaoMatSach }.count
    }
    
    // Kiểm tra xem độc giả có phải là VIP hay không:
    // Quy định: Độc giả có nạp tiền (số dư ví > 0đ) hoặc được xếp hạng "VIP" thì là VIP
    // Nếu không nạp tiền vào tài khoản (số dư = 0đ) là Thường
    var isVIP: Bool {
        soDuTaiKhoan > 0 || loaiThe == "VIP"
    }
}