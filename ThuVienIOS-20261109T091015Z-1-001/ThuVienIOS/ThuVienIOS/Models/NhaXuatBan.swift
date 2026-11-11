//
//  NhaXuatBan.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Nhà Xuất Bản (Ví dụ: NXB Trẻ, NXB Kim Đồng...)
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class NhaXuatBan: Identifiable, ObservableObject, Hashable {
    var maNXB: UUID
    @Published var tenNXB: String
    var dsSach: [Sach] = []
    
    var id: UUID { maNXB }
    
    init(maNXB: UUID = UUID(), tenNXB: String) {
        self.maNXB = maNXB
        self.tenNXB = tenNXB
    }
    
    static func == (lhs: NhaXuatBan, rhs: NhaXuatBan) -> Bool {
        lhs.maNXB == rhs.maNXB
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maNXB)
    }
}
