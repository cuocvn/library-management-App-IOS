//
//  NhaXuatBan.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class NhaXuatBan {
    @Attribute(.unique) var maNXB: UUID
    var tenNXB: String
    
    @Relationship(deleteRule: .nullify, inverse: \Sach.nhaXuatBan)
    var dsSach: [Sach] = []
    
    init(maNXB: UUID = UUID(), tenNXB: String) {
        self.maNXB = maNXB
        self.tenNXB = tenNXB
    }
}
