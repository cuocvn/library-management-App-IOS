//
//  TheLoai.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Thể Loại Sách (Ví dụ: CNTT, Kinh tế, Văn học...)
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import Foundation

final class TheLoai: Identifiable, ObservableObject, Hashable {
    var maTheLoai: UUID
    @Published var tenTheLoai: String
    var dsSach: [Sach] = []
    
    var id: UUID { maTheLoai }
    
    init(maTheLoai: UUID = UUID(), tenTheLoai: String) {
        self.maTheLoai = maTheLoai
        self.tenTheLoai = tenTheLoai
    }
    
    static func == (lhs: TheLoai, rhs: TheLoai) -> Bool {
        lhs.maTheLoai == rhs.maTheLoai
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(maTheLoai)
    }
}
