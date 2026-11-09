//
//  PhieuMuon.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class PhieuMuon {
    @Attribute(.unique) var maPhieu: UUID
    var ngayMuon: Date
    var hanTra: Date
    var ngayTra: Date?
    
    var tienCocThucTe: Int // VNĐ (0 nếu là VIP)
    var phiMuonThucTe: Int // VNĐ
    
    // Snapshot tài chính lúc trả sách (bất biến sau khi trả)
    var soNgayTre: Int?
    var tienPhat: Int?
    var phuongThucThanhToan: String? // "TienMat" hoặc "TaiKhoan"
    var phuongThucHoanTien: String?  // "TienMat" hoặc "TaiKhoan"
    
    var banSao: BanSaoSach?
    var docGia: DocGia?
    
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
        self.banSao = banSao
        self.docGia = docGia
    }
    
    // Thuộc tính tiện ích
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
        if daTra {
            return "Đã trả"
        } else if isQuaHan {
            return "Quá hạn"
        } else {
            return "Đang mượn"
        }
    }
}
