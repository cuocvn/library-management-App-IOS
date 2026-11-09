//
//  TheLoai.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Thể Loại Sách (Ví dụ: CNTT, Kinh tế, Văn học...)
//  CÔNG NGHỆ: SwiftData (@Model) - Tương đương 1 bảng (Table) trong Database
//

import Foundation
import SwiftData

@Model
final class TheLoai {
    // Khóa chính duy nhất của thể loại
    @Attribute(.unique) var maTheLoai: UUID
    
    // Tên thể loại hiển thị (VD: "Công nghệ thông tin")
    var tenTheLoai: String
    
    // Mối quan hệ 1-Nhiều: Một thể loại có thể chứa nhiều cuốn sách.
    // deleteRule: .nullify -> Khi xóa thể loại, các sách thuộc thể loại này sẽ không bị xóa mất
    // mà chỉ chuyển trường `theLoai` về nil (nhóm chung) để bảo toàn dữ liệu sách an toàn.
    @Relationship(deleteRule: .nullify, inverse: \Sach.theLoai)
    var dsSach: [Sach] = []
    
    // Hàm khởi tạo (Constructor)
    init(maTheLoai: UUID = UUID(), tenTheLoai: String) {
        self.maTheLoai = maTheLoai
        self.tenTheLoai = tenTheLoai
    }
}