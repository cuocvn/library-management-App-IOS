//
//  Sach.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Đầu Sách (Metadata tổng quan của tác phẩm)
//  VÍ DỤ: "Clean Code" là 1 đầu sách, trong đó có thể có 3 cuốn bản sao vật lý trên kệ.
//  CÔNG NGHỆ: SwiftData (@Model)
//

import Foundation
import SwiftData

@Model
final class Sach {
    // Khóa chính định danh duy nhất của đầu sách
    @Attribute(.unique) var maSach: UUID
    
    // Tên đầu sách
    var tenSach: String
    
    // Năm xuất bản
    var namXuatBan: Int
    
    // Phân loại giá trị sách: "Truyện tranh", "Sách thường", "Giáo trình", "Sách quý"
    // Dùng để tự động tính tiền cọc và phí mượn phù hợp
    var phanLoaiGiaTri: String
    
    // Tiền cọc cơ bản của cuốn sách (đơn vị: VNĐ)
    var tienCoc: Int
    
    // Phí mượn cơ bản cho mỗi lần mượn (đơn vị: VNĐ)
    var phiMuon: Int
    
    // Cờ xóa mềm (Soft Delete): true nghĩa là sách đã bị ẩn/xóa, không hiện trên danh sách chính
    var daAn: Bool
    
    // Ảnh bìa sách dạng nhị phân (nếu người dùng tải ảnh từ máy lên)
    var hinhAnh: Data?
    
    // Mối quan hệ liên kết đến Thể Loại, Nhà Xuất Bản, Tác Giả (N - 1)
    var theLoai: TheLoai?
    var nhaXuatBan: NhaXuatBan?
    var tacGia: TacGia?
    
    // Mối quan hệ 1-Nhiều: Một đầu sách quản lý danh sách các cuốn bản sao vật lý thực tế.
    // deleteRule: .cascade -> Khi xóa đầu sách, toàn bộ các bản sao của nó cũng được xóa theo.
    @Relationship(deleteRule: .cascade, inverse: \BanSaoSach.sach)
    var dsBanSao: [BanSaoSach] = []
    
    // Hàm khởi tạo (Constructor)
    init(
        maSach: UUID = UUID(),
        tenSach: String,
        namXuatBan: Int = Calendar.current.component(.year, from: Date()),
        phanLoaiGiaTri: String = "Sách thường",
        tienCoc: Int = 50000,
        phiMuon: Int = 5000,
        daAn: Bool = false,
        hinhAnh: Data? = nil,
        theLoai: TheLoai? = nil,
        nhaXuatBan: NhaXuatBan? = nil,
        tacGia: TacGia? = nil
    ) {
        self.maSach = maSach
        self.tenSach = tenSach
        self.namXuatBan = namXuatBan
        self.phanLoaiGiaTri = phanLoaiGiaTri
        self.tienCoc = tienCoc
        self.phiMuon = phiMuon
        self.daAn = daAn
        self.hinhAnh = hinhAnh
        self.theLoai = theLoai
        self.nhaXuatBan = nhaXuatBan
        self.tacGia = tacGia
    }
    
    // MARK: - Các thuộc tính tính toán (Computed Properties)
    
    // Số lượng cuốn vật lý đang có tình trạng "SanSang" (có thể cho mượn ngay)
    var soLuongKhaDung: Int {
        dsBanSao.filter { $0.tinhTrang == "SanSang" }.count
    }
    
    // Tổng số lượng bản sao vật lý mà thư viện đang sở hữu
    var tongSoBanSao: Int {
        dsBanSao.count
    }
}