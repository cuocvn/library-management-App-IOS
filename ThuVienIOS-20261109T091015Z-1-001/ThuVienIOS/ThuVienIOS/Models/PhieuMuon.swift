//
//  PhieuMuon.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Giao dịch Mượn & Trả Sách
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class PhieuMuon: Identifiable, ObservableObject, Hashable {
    var maPhieu: UUID
    @Published var ngayMuon: Date
    @Published var hanTra: Date
    @Published var ngayTra: Date?
    @Published var tienCocThucTe: Int
    @Published var phiMuonThucTe: Int
    @Published var soNgayTre: Int?
    @Published var tienPhat: Int?
    @Published var phuongThucThanhToan: String?
    @Published var phuongThucHoanTien: String?
    @Published var ghiChu: String?
    @Published var daBaoMatSach: Bool
    
    @Published var banSao: BanSaoSach?
    @Published var docGia: DocGia?
    
    var id: UUID { maPhieu }
    
    init(
        maPhieu: UUID = UUID(),
        ngayMuon: Date = Date(),
        hanTra: Date,
        ngayTra: Date? = nil,
        tienCocThucTe: Int = 0,
        phiMuonThucTe: Int = 0,
        soNgayTre: Int? = nil,
        tienPhat: Int? = nil,
        phuongThucThanhToan: String? = "TienMat",
        phuongThucHoanTien: String? = nil,
        ghiChu: String? = "",
        daBaoMatSach: Bool = false,
        banSao: BanSaoSach? = nil,
        docGia: DocGia? = nil
    ) {
        self.maPhieu = maPhieu
        self.ngayMuon = ngayMuon
        self.hanTra = hanTra
        self.ngayTra = ngayTra
        self.tienCocThucTe = tienCocThucTe
        self.phiMuonThucTe = phiMuonThucTe
        self.soNgayTre = soNgayTre
        self.tienPhat = tienPhat
        self.phuongThucThanhToan = phuongThucThanhToan
        self.phuongThucHoanTien = phuongThucHoanTien
        self.ghiChu = ghiChu
        self.daBaoMatSach = daBaoMatSach
        self.banSao = banSao
        self.docGia = docGia
    }
    
    var daTra: Bool {
        ngayTra != nil
    }
    
    var isQuaHan: Bool {
        if let ngayTra = ngayTra {
            return ngayTra > hanTra
        }
        return Date() > hanTra
    }
    
    var tinhTrangHienThi: String {
        if daBaoMatSach {
            return "Không trả (Mất)"
        } else if daTra {
            return "Đã trả"
        } else if isQuaHan {
            return "Quá hạn"
        } else {
            return "Đang mượn"
        }
    }
    
    static func == (lhs: PhieuMuon, rhs: PhieuMuon) -> Bool {
        lhs.maPhieu == rhs.maPhieu
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maPhieu)
    }
}
