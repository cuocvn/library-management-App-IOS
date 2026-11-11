//
//  Sach.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Đầu Sách (Metadata tổng quan của tác phẩm)
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class Sach: Identifiable, ObservableObject, Hashable {
    var maSach: UUID
    @Published var tenSach: String
    @Published var namXuatBan: Int
    @Published var phanLoaiGiaTri: String
    @Published var tienCoc: Int
    @Published var phiMuon: Int
    @Published var daAn: Bool
    @Published var hinhAnh: Data?
    
    @Published var theLoai: TheLoai?
    @Published var nhaXuatBan: NhaXuatBan?
    @Published var tacGia: TacGia?
    @Published var dsBanSao: [BanSaoSach] = []
    
    var id: UUID { maSach }
    
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
    
    var soLuongKhaDung: Int {
        dsBanSao.filter { $0.tinhTrang == "SanSang" }.count
    }
    
    var tongSoBanSao: Int {
        dsBanSao.count
    }
    
    static func == (lhs: Sach, rhs: Sach) -> Bool {
        lhs.maSach == rhs.maSach
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maSach)
    }
}
