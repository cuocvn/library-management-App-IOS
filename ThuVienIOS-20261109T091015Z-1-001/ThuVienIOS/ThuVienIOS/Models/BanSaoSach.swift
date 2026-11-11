//
//  BanSaoSach.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Bản Sao Vật Lý của cuốn sách
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class BanSaoSach: Identifiable, ObservableObject, Hashable {
    var maDinhDanh: String
    @Published var viTriKe: String
    @Published var tinhTrang: String
    
    weak var sach: Sach?
    var dsPhieuMuon: [PhieuMuon] = []
    
    var id: String { maDinhDanh }
    
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
    
    static func == (lhs: BanSaoSach, rhs: BanSaoSach) -> Bool {
        lhs.maDinhDanh == rhs.maDinhDanh
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maDinhDanh)
    }
}
