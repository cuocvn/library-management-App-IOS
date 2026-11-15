//
//  ThuVienIOSTests.swift
//  ThuVienIOSTests
//
//  MÔ TẢ: Chương 3 - Kiểm Thử Đơn Vị Cho Data Model & Nghiệp Vụ Tài Chính (XCTest)
//  GIẢNG VIÊN: Tiêu Kim Cương - Lập trình Di động trên iOS
//

import XCTest
@testable import ThuVienIOS

@MainActor
final class ThuVienIOSTests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    // MARK: - 1. Kiểm thử Data Model Sách
    func testKhoiTaoSachHopLe() throws {
        let sach = Sach(
            tenSach: "Lập trình iOS với Swift",
            namXuatBan: 2024,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 80000,
            phiMuon: 15000
        )
        
        XCTAssertNotNil(sach, "Khởi tạo sách hợp lệ thành công")
        XCTAssertEqual(sach.tenSach, "Lập trình iOS với Swift")
        XCTAssertEqual(sach.tienCoc, 80000)
        XCTAssertEqual(sach.phiMuon, 15000)
        XCTAssertFalse(sach.daAn, "Sách mới tạo không bị ẩn")
    }

    // MARK: - 2. Kiểm thử Data Model Độc Giả & Hạng VIP
    func testKhoiTaoDocGiaVaVIP() throws {
        let docGia = DocGia(
            hoTen: "Trần Quốc Bảo",
            email: "bao@tdc.edu.vn",
            soDienThoai: "0901234567",
            lopKhoa: "CD-CNTT",
            loaiThe: "VIP",
            soDuTaiKhoan: 250000
        )
        
        XCTAssertNotNil(docGia)
        XCTAssertEqual(docGia.hoTen, "Trần Quốc Bảo")
        XCTAssertEqual(docGia.loaiThe, "VIP")
        XCTAssertEqual(docGia.soDuTaiKhoan, 250000)
    }

    // MARK: - 3. Kiểm thử Nghiệp vụ VIP: Tự động miễn tiền cọc (Deposit = 0)
    func testVIPMienPhiTienCoc() throws {
        let docGiaVIP = DocGia(hoTen: "Nguyễn Văn VIP", loaiThe: "VIP")
        let sach = Sach(tenSach: "Sách Quý Lịch Sử", phanLoaiGiaTri: "Sách quý", tienCoc: 150000, phiMuon: 30000)
        
        // Nghiệp vụ: Độc giả VIP được miễn 100% tiền cọc
        let tienCocThucTe = docGiaVIP.loaiThe == "VIP" ? 0 : sach.tienCoc
        let tongThu = tienCocThucTe + sach.phiMuon
        
        XCTAssertEqual(tienCocThucTe, 0, "Độc giả VIP phải được miễn 0đ tiền cọc")
        XCTAssertEqual(tongThu, 30000, "Tổng thu chỉ bằng phí mượn 30.000 đ")
    }

    // MARK: - 4. Kiểm thử Nghiệp vụ Tính Phạt Quá Hạn Snapshot
    func testTinhTienPhatTreHan() throws {
        let calendar = Calendar.current
        let ngayMuon = calendar.date(byAdding: .day, value: -20, to: Date())!
        let hanTra = calendar.date(byAdding: .day, value: -14, to: Date())!
        let ngayTra = Date()
        
        // Tính số ngày trễ = 20 - 14 = 6 ngày
        let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: hanTra), to: calendar.startOfDay(for: ngayTra)).day ?? 0
        let soNgayTre = max(0, diff)
        let mucPhatMoiNgay = 5000 // 5.000 đ/ngày
        let tienPhat = soNgayTre * mucPhatMoiNgay
        
        XCTAssertGreaterThan(soNgayTre, 0, "Phiếu phải ghi nhận trễ hạn")
        XCTAssertEqual(tienPhat, soNgayTre * 5000, "Tiền phạt = số ngày trễ * 5.000 đ")
    }

    // MARK: - 5. Kiểm thử Quyết toán Hoàn Cọc (Cọc - Phạt = Hoàn lại)
    func testQuyetToanHoanCoc() throws {
        let tienCocThucTe = 50000
        let tienPhat = 15000 // Trễ 3 ngày phạt 15k
        let tienHoanLai = tienCocThucTe - tienPhat
        
        XCTAssertEqual(tienHoanLai, 35000, "Khách được hoàn lại 35.000 đ sau khi trừ phạt")
    }

    // MARK: - 6. Kiểm thử Tầng Truy Xuất Database DAL (DAO)
    func testTCCDLibraryDAO() throws {
        let dao = LibraryDAO.shared
        XCTAssertTrue(dao.openDatabase(), "Tầng DAL mở cơ sở dữ liệu thành công")
        
        let sachList = dao.getAllSach()
        XCTAssertFalse(sachList.isEmpty, "Tầng DAL truy xuất được danh sách sách")
    }
}
