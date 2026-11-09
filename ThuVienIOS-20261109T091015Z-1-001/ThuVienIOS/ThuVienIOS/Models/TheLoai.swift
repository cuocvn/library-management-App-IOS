//
//  TheLoai.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class TheLoai {
    @Attribute(.unique) var maTheLoai: UUID
    var tenTheLoai: String
    
    @Relationship(deleteRule: .nullify, inverse: \Sach.theLoai)
    var dsSach: [Sach] = []
    
    init(maTheLoai: UUID = UUID(), tenTheLoai: String) {
        self.maTheLoai = maTheLoai
        self.tenTheLoai = tenTheLoai
    }
}
