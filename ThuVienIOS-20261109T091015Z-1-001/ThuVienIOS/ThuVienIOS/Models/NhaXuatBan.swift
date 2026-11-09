//
//  NhaXuatBan.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Nhà Xuất Bản (Ví dụ: NXB Trẻ, NXB Kim Đồng...)
//  CÔNG NGHỆ: SwiftData (@Model)
//

import Foundation
import SwiftData

@Model
final class NhaXuatBan {
    // Khóa chính duy nhất của Nhà Xuất Bản
    @Attribute(.unique) var maNXB: UUID
    
    // Tên Nhà Xuất Bản (VD: "NXB Trẻ")
    var tenNXB: String
    
    // Mối quan hệ 1-Nhiều: Một NXB có thể xuất bản nhiều cuốn sách.
    // deleteRule: .nullify -> Khi xóa NXB, sách vẫn được giữ lại an toàn.
    @Relationship(deleteRule: .nullify, inverse: \Sach.nhaXuatBan)
    var dsSach: [Sach] = []
    
    // Hàm khởi tạo
    init(maNXB: UUID = UUID(), tenNXB: String) {
        self.maNXB = maNXB
        self.tenNXB = tenNXB
    }
}