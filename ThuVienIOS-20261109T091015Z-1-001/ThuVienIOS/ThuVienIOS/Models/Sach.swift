//
//  Sach.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class Sach {
    @Attribute(.unique) var maSach: UUID
    var tenSach: String
    var namXuatBan: Int
    var phanLoaiGiaTri: String // "Truyện tranh", "Sách thường", "Giáo trình", "Sách quý"
    var tienCoc: Int
    var phiMuon: Int
    var daAn: Bool
    var hinhAnh: Data?
    
    var theLoai: TheLoai?
    var nhaXuatBan: NhaXuatBan?
    var tacGia: TacGia?
    
    @Relationship(deleteRule: .cascade, inverse: \BanSaoSach.sach)
    var dsBanSao: [BanSaoSach] = []
    
    init(
        maSach: UUID = UUID(),
        tenSach: String,
        namXuatBan: Int = Calendar.current.component(.year, from: Date()),
        phanLoaiGiaTri: String = "Sách thường",
        tienCoc: Int = 50000,
        phiMuon: Int = 5000,
        daAn: Bool = false,
        hinhAnh: Data? = nil,
        theLoai: TheLoai? = nil,
        nhaXuatBan: NhaXuatBan? = nil,
        tacGia: TacGia? = nil
    ) {
        self.maSach = maSach
        self.tenSach = tenSach
        self.namXuatBan = namXuatBan
        self.phanLoaiGiaTri = phanLoaiGiaTri
        self.tienCoc = tienCoc
        self.phiMuon = phiMuon
        self.daAn = daAn
        self.hinhAnh = hinhAnh
        self.theLoai = theLoai
        self.nhaXuatBan = nhaXuatBan
        self.tacGia = tacGia
    }
    
    // Thuộc tính tiện ích
    var soLuongKhaDung: Int {
        dsBanSao.filter { $0.tinhTrang == "SanSang" }.count
    }
    
    var tongSoBanSao: Int {
        dsBanSao.count
    }
}
