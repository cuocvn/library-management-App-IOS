//
//  BanSaoSach.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Bản Sao Vật Lý của cuốn sách (Điểm nhấn sáng tạo của đồ án)
//  Thay vì chỉ lưu số lượng chung chung, app theo dõi từng cuốn cụ thể trên giá kệ.
//  VÍ DỤ: Cuốn "CC-001" đang ở Kệ A1-01, cuốn "CC-002" đang có người mượn.
//

import Foundation
import SwiftData

@Model
final class BanSaoSach {
    // Mã định danh duy nhất của từng cuốn vật lý (VD: "CC-001", "SW-002")
    @Attribute(.unique) var maDinhDanh: String
    
    // Vị trí lưu trữ thực tế trên giá kệ của thư viện (VD: "Kệ A1", "Dãy B2")
    var viTriKe: String
    
    // Tình trạng hiện tại của cuốn sách:
    // - "SanSang": Đang nằm trên kệ, sẵn sàng cho bạn đọc mượn
    // - "DangMuon": Đang có bạn đọc mượn mang về
    // - "Hong": Sách bị rách, ướt, hư hỏng hoặc thất lạc
    var tinhTrang: String
    
    // Liên kết ngược về Đầu Sách cha (Metadata)
    var sach: Sach?
    
    // Danh sách toàn bộ lịch sử các lần mượn/trả của riêng cuốn sách này
    @Relationship(deleteRule: .cascade, inverse: \PhieuMuon.banSao)
    var dsPhieuMuon: [PhieuMuon] = []
    
    // Hàm khởi tạo
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
}