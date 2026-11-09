//
//  BanSaoSach.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class BanSaoSach {
    @Attribute(.unique) var maDinhDanh: String // Ví dụ: AI-001, TT-002
    var viTriKe: String // Ví dụ: Kệ A1, Dãy B2
    var tinhTrang: String // "SanSang", "DangMuon", "Hong"
    
    var sach: Sach?
    
    @Relationship(deleteRule: .cascade, inverse: \PhieuMuon.banSao)
    var dsPhieuMuon: [PhieuMuon] = []
    
    init(
        maDinhDanh: String,
        viTriKe: String = "Kệ A1",
        tinhTrang: String = "SanSang",
        sach: Sach? = nil
    ) {
        self.maDinhDanh = maDinhDanh
        self.viTriKe = viTriKe
        self.tinhTrang = tinhTrang
        self.sach = sach
    }
}
