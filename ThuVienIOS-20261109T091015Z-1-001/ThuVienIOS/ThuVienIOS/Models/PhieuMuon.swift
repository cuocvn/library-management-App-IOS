//
//  PhieuMuon.swift
//  ThuVienIOS
//
//  MÔ TẢ: Model quản lý Giao dịch Mượn & Trả Sách
//  ĐIỂM NHẤN: Áp dụng cơ chế "Snapshot tài chính bất biến".
//  Khi trả sách, số ngày trễ và tiền phạt được "chụp" lại và lưu cố định vào phiếu.
//  Nếu sau này thủ thư thay đổi đơn giá phạt trong cài đặt, lịch sử cũ vẫn bảo toàn 100%.
//

import Foundation
import SwiftData

@Model
final class PhieuMuon {
    // Khóa chính định danh duy nhất của phiếu mượn
    @Attribute(.unique) var maPhieu: UUID
    
    // Ngày bắt đầu mượn sách
    var ngayMuon: Date
    
    // Hạn chót phải trả sách theo quy định
    var hanTra: Date
    
    // Ngày trả sách thực tế (nil nếu sách đang được mượn, chưa trả)
    var ngayTra: Date?
    
    // Tiền cọc thực tế thu của lần mượn này (VNĐ). Sẽ bằng 0 nếu độc giả là VIP.
    var tienCocThucTe: Int
    
    // Phí mượn thực tế thu của lần mượn này (VNĐ)
    var phiMuonThucTe: Int
    
    // MARK: - Snapshot Tài Chính Lúc Trả Sách (Bảo toàn lịch sử bất biến)
    // Số ngày bạn đọc bị trễ hạn lúc trả sách
    var soNgayTre: Int?
    
    // Số tiền phạt quá hạn đã thu (Số ngày trễ x Đơn giá phạt)
    var tienPhat: Int?
    
    // Phương thức thanh toán lúc mượn: "TienMat" hoặc "TaiKhoan" (trừ ví)
    var phuongThucThanhToan: String?
    
    // Phương thức hoàn tiền cọc thừa lúc trả: "TienMat" hoặc "TaiKhoan" (cộng ví)
    var phuongThucHoanTien: String?
    
    // Cuốn sách vật lý cụ thể được mượn
    var banSao: BanSaoSach?
    
    // Độc giả thực hiện mượn sách
    var docGia: DocGia?
    
    // Hàm khởi tạo
    init(
        maPhieu: UUID = UUID(),
        ngayMuon: Date = Date(),
        hanTra: Date,
        ngayTra: Date? = nil,
        tienCocThucTe: Int = 0,
        phiMuonThucTe: Int = 0,
        soNgayTre: Int? = nil,
        tienPhat: Int? = nil,
        phuongThucThanhToan: String? = "TienMat",
        phuongThucHoanTien: String? = nil,
        banSao: BanSaoSach? = nil,
        docGia: DocGia? = nil
    ) {
        self.maPhieu = maPhieu
        self.ngayMuon = ngayMuon
        self.hanTra = hanTra
        self.ngayTra = ngayTra
        self.tienCocThucTe = tienCocThucTe
        self.phiMuonThucTe = phiMuonThucTe
        self.soNgayTre = soNgayTre
        self.tienPhat = tienPhat
        self.phuongThucThanhToan = phuongThucThanhToan
        self.phuongThucHoanTien = phuongThucHoanTien
        self.banSao = banSao
        self.docGia = docGia
    }
    
    // MARK: - Các thuộc tính tính toán (Computed Properties)
    
    // Kiểm tra xem phiếu mượn đã hoàn tất trả sách hay chưa
    var daTra: Bool {
        ngayTra != nil
    }
    
    // Kiểm tra xem phiếu mượn có bị quá hạn hay không
    var isQuaHan: Bool {
        if let ngayTra = ngayTra {
            return ngayTra > hanTra
        }
        return Date() > hanTra
    }
    
    // Nhãn hiển thị trạng thái bằng tiếng Việt trên giao diện
    var tinhTrangHienThi: String {
        if daTra {
            return "Đã trả"
        } else if isQuaHan {
            return "Quá hạn"
        } else {
            return "Đang mượn"
        }
    }
}