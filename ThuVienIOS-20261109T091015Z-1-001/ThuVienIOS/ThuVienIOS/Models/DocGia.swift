//
//  DocGia.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class DocGia {
    @Attribute(.unique) var maDocGia: UUID
    var hoTen: String
    var email: String
    var soDienThoai: String
    var lopKhoa: String
    var loaiThe: String // "Thuong", "VIP"
    var soDuTaiKhoan: Int // VNĐ
    var daAn: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \PhieuMuon.docGia)
    var dsPhieuMuon: [PhieuMuon] = []
    
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
    
    // Thuộc tính tiện ích
    var soSachDangMuon: Int {
        dsPhieuMuon.filter { $0.ngayTra == nil }.count
    }
    
    var isVIP: Bool {
        loaiThe == "VIP"
    }
}
