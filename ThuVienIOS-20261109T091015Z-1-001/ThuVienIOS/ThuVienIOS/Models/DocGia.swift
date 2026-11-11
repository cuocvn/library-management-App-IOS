//
//  DocGia.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Bạn Đọc / Độc Giả của Thư viện
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class DocGia: Identifiable, ObservableObject, Hashable {
    var maDocGia: UUID
    @Published var hoTen: String
    @Published var email: String
    @Published var soDienThoai: String
    @Published var lopKhoa: String
    @Published var loaiThe: String
    @Published var soDuTaiKhoan: Int
    @Published var daAn: Bool
    @Published var dsPhieuMuon: [PhieuMuon] = []
    
    var id: UUID { maDocGia }
    
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
    
    var isVIP: Bool {
        loaiThe == "VIP" || soDuTaiKhoan > 0
    }
    
    var soSachDangMuon: Int {
        dsPhieuMuon.filter { $0.ngayTra == nil }.count
    }
    
    var soSachQuaHan: Int {
        dsPhieuMuon.filter { $0.ngayTra == nil && $0.isQuaHan }.count
    }
    
    var soSachBaoMat: Int {
        dsPhieuMuon.filter { $0.daBaoMatSach }.count
    }
    
    static func == (lhs: DocGia, rhs: DocGia) -> Bool {
        lhs.maDocGia == rhs.maDocGia
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maDocGia)
    }
}
