//
//  TacGia.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@Model
final class TacGia {
    @Attribute(.unique) var maTacGia: UUID
    var tenTacGia: String
    
    @Relationship(deleteRule: .nullify, inverse: \Sach.tacGia)
    var dsSach: [Sach] = []
    
    init(maTacGia: UUID = UUID(), tenTacGia: String) {
        self.maTacGia = maTacGia
        self.tenTacGia = tenTacGia
    }
}
