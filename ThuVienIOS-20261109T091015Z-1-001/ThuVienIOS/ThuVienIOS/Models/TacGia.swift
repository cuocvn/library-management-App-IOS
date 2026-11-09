//
//  TacGia.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Tác Giả (Ví dụ: Robert C. Martin, Nguyễn Nhật Ánh...)
//  CÔNG NGHỆ: SwiftData (@Model)
//

import Foundation
import SwiftData

@Model
final class TacGia {
    // Khóa chính duy nhất của Tác giả
    @Attribute(.unique) var maTacGia: UUID
    
    // Tên tác giả (VD: "Nguyễn Nhật Ánh")
    var tenTacGia: String
    
    // Mối quan hệ 1-Nhiều: Một tác giả có thể có nhiều tác phẩm sách.
    // deleteRule: .nullify -> Khi xóa tác giả, sách vẫn được giữ lại an toàn.
    @Relationship(deleteRule: .nullify, inverse: \Sach.tacGia)
    var dsSach: [Sach] = []
    
    // Hàm khởi tạo
    init(maTacGia: UUID = UUID(), tenTacGia: String) {
        self.maTacGia = maTacGia
        self.tenTacGia = tenTacGia
    }
}