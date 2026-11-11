//
//  TacGia.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Tác Giả (Ví dụ: Robert C. Martin, Nguyễn Nhật Ánh...)
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class TacGia: Identifiable, ObservableObject, Hashable {
    var maTacGia: UUID
    @Published var tenTacGia: String
    var dsSach: [Sach] = []
    
    var id: UUID { maTacGia }
    
    init(maTacGia: UUID = UUID(), tenTacGia: String) {
        self.maTacGia = maTacGia
        self.tenTacGia = tenTacGia
    }
    
    static func == (lhs: TacGia, rhs: TacGia) -> Bool {
        lhs.maTacGia == rhs.maTacGia
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maTacGia)
    }
}
