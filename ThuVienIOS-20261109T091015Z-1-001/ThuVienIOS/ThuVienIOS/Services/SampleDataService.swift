//
//  SampleDataService.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@MainActor
final class SampleDataService {
    
    // Xóa sạch toàn bộ dữ liệu trong cơ sở dữ liệu để đưa về trạng thái trắng (Reset)
    static func xoaToanBoDuLieu(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: PhieuMuon.self)
            try modelContext.delete(model: BanSaoSach.self)
            try modelContext.delete(model: Sach.self)
            try modelContext.delete(model: DocGia.self)
            try modelContext.delete(model: TheLoai.self)
            try modelContext.delete(model: NhaXuatBan.self)
            try modelContext.delete(model: TacGia.self)
            try modelContext.save()
        } catch {
            print("Lỗi khi xóa dữ liệu: \(error)")
        }
    }
    
    // Nạp dữ liệu mẫu chuẩn: Đúng 10 Sách, 3 Độc giả, và các phiếu mượn khớp toán học 100%
    static func napDuLieuChuan10Sach(modelContext: ModelContext) {
        // Xóa dữ liệu cũ trước khi nạp để đảm bảo sạch và khớp số liệu
        xoaToanBoDuLieu(modelContext: modelContext)
        
        // 1. Thể loại (4 thể loại)
        let tlCNTT = TheLoai(tenTheLoai: "Công nghệ thông tin")
        let tlKinhTe = TheLoai(tenTheLoai: "Kinh tế & Đầu tư")
        let tlKyNang = TheLoai(tenTheLoai: "Kỹ năng & Phát triển")
        let tlVanHoc = TheLoai(tenTheLoai: "Văn học & Nghệ thuật")
        [tlCNTT, tlKinhTe, tlKyNang, tlVanHoc].forEach { modelContext.insert($0) }
        
        // 2. Nhà xuất bản (4 NXB)
        let nxbKHTN = NhaXuatBan(tenNXB: "NXB Khoa Học & Kỹ Thuật")
        let nxbTre = NhaXuatBan(tenNXB: "NXB Trẻ")
        let nxbLaoDong = NhaXuatBan(tenNXB: "NXB Lao Động - Xã Hội")
        let nxbKimDong = NhaXuatBan(tenNXB: "NXB Kim Đồng")
        [nxbKHTN, nxbTre, nxbLaoDong, nxbKimDong].forEach { modelContext.insert($0) }
        
        // 3. Tác giả (5 tác giả)
        let tgUncleBob = TacGia(tenTacGia: "Robert C. Martin")
        let tgPaul = TacGia(tenTacGia: "Paul Hudson")
        let tgCarnegie = TacGia(tenTacGia: "Dale Carnegie")
        let tgHousel = TacGia(tenTacGia: "Morgan Housel")
        let tgAnh = TacGia(tenTacGia: "Nguyễn Nhật Ánh")
        [tgUncleBob, tgPaul, tgCarnegie, tgHousel, tgAnh].forEach { modelContext.insert($0) }
        
        // 4. Đúng 10 đầu sách & bản sao vật lý
        // Sách 1: Clean Code
        let s1 = Sach(
            tenSach: "Clean Code - Nghệ thuật viết code sạch",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 120000,
            phiMuon: 15000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgUncleBob
        )
        modelContext.insert(s1)
        let bs1_1 = BanSaoSach(maDinhDanh: "CC-001", viTriKe: "Kệ A1-01", tinhTrang: "SanSang", sach: s1)
        let bs1_2 = BanSaoSach(maDinhDanh: "CC-002", viTriKe: "Kệ A1-02", tinhTrang: "DangMuon", sach: s1)
        [bs1_1, bs1_2].forEach { s1.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 2: SwiftUI & SwiftData Masterclass
        let s2 = Sach(
            tenSach: "Lập trình iOS với SwiftUI & SwiftData",
            namXuatBan: 2024,
            phanLoaiGiaTri: "Sách quý",
            tienCoc: 200000,
            phiMuon: 30000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgPaul
        )
        modelContext.insert(s2)
        let bs2_1 = BanSaoSach(maDinhDanh: "SW-001", viTriKe: "Kệ A2-01", tinhTrang: "DangMuon", sach: s2)
        let bs2_2 = BanSaoSach(maDinhDanh: "SW-002", viTriKe: "Kệ A2-02", tinhTrang: "SanSang", sach: s2)
        [bs2_1, bs2_2].forEach { s2.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 3: Đắc Nhân Tâm
        let s3 = Sach(
            tenSach: "Đắc Nhân Tâm (How to Win Friends)",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKyNang,
            nhaXuatBan: nxbTre,
            tacGia: tgCarnegie
        )
        modelContext.insert(s3)
        let bs3_1 = BanSaoSach(maDinhDanh: "DNT-001", viTriKe: "Kệ B1-01", tinhTrang: "DangMuon", sach: s3)
        let bs3_2 = BanSaoSach(maDinhDanh: "DNT-002", viTriKe: "Kệ B1-02", tinhTrang: "SanSang", sach: s3)
        let bs3_3 = BanSaoSach(maDinhDanh: "DNT-003", viTriKe: "Kệ B1-03", tinhTrang: "SanSang", sach: s3)
        [bs3_1, bs3_2, bs3_3].forEach { s3.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 4: Tâm Lý Học Về Tiền
        let s4 = Sach(
            tenSach: "Tâm Lý Học Về Tiền (The Psychology of Money)",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKinhTe,
            nhaXuatBan: nxbLaoDong,
            tacGia: tgHousel
        )
        modelContext.insert(s4)
        let bs4_1 = BanSaoSach(maDinhDanh: "TLT-001", viTriKe: "Kệ B2-01", tinhTrang: "SanSang", sach: s4)
        let bs4_2 = BanSaoSach(maDinhDanh: "TLT-002", viTriKe: "Kệ B2-02", tinhTrang: "SanSang", sach: s4)
        [bs4_1, bs4_2].forEach { s4.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 5: Mắt Biếc
        let s5 = Sach(
            tenSach: "Mắt Biếc",
            namXuatBan: 2021,
            phanLoaiGiaTri: "Truyện tranh",
            tienCoc: 60000,
            phiMuon: 8000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbTre,
            tacGia: tgAnh
        )
        modelContext.insert(s5)
        let bs5_1 = BanSaoSach(maDinhDanh: "MB-001", viTriKe: "Kệ C1-01", tinhTrang: "SanSang", sach: s5)
        let bs5_2 = BanSaoSach(maDinhDanh: "MB-002", viTriKe: "Kệ C1-02", tinhTrang: "SanSang", sach: s5)
        [bs5_1, bs5_2].forEach { s5.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 6: Cho Tôi Xin Một Vé Đi Tuổi Thơ
        let s6 = Sach(
            tenSach: "Cho Tôi Xin Một Vé Đi Tuổi Thơ",
            namXuatBan: 2020,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbTre,
            tacGia: tgAnh
        )
        modelContext.insert(s6)
        let bs6_1 = BanSaoSach(maDinhDanh: "VTT-001", viTriKe: "Kệ C1-03", tinhTrang: "SanSang", sach: s6)
        let bs6_2 = BanSaoSach(maDinhDanh: "VTT-002", viTriKe: "Kệ C1-04", tinhTrang: "SanSang", sach: s6)
        [bs6_1, bs6_2].forEach { s6.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 7: Clean Architecture
        let s7 = Sach(
            tenSach: "Clean Architecture - Kiến trúc phần mềm sạch",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 120000,
            phiMuon: 15000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgUncleBob
        )
        modelContext.insert(s7)
        let bs7_1 = BanSaoSach(maDinhDanh: "CA-001", viTriKe: "Kệ A1-04", tinhTrang: "SanSang", sach: s7)
        let bs7_2 = BanSaoSach(maDinhDanh: "CA-002", viTriKe: "Kệ A1-05", tinhTrang: "SanSang", sach: s7)
        [bs7_1, bs7_2].forEach { s7.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 8: Khởi Nghiệp Tinh Gọn
        let s8 = Sach(
            tenSach: "Khởi Nghiệp Tinh Gọn (The Lean Startup)",
            namXuatBan: 2021,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKinhTe,
            nhaXuatBan: nxbLaoDong,
            tacGia: tgHousel
        )
        modelContext.insert(s8)
        let bs8_1 = BanSaoSach(maDinhDanh: "LS-001", viTriKe: "Kệ B2-03", tinhTrang: "SanSang", sach: s8)
        let bs8_2 = BanSaoSach(maDinhDanh: "LS-002", viTriKe: "Kệ B2-04", tinhTrang: "SanSang", sach: s8)
        [bs8_1, bs8_2].forEach { s8.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 9: Quẳng Gánh Lo Đi Và Vui Sống
        let s9 = Sach(
            tenSach: "Quẳng Gánh Lo Đi Và Vui Sống",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKyNang,
            nhaXuatBan: nxbTre,
            tacGia: tgCarnegie
        )
        modelContext.insert(s9)
        let bs9_1 = BanSaoSach(maDinhDanh: "QGL-001", viTriKe: "Kệ B1-04", tinhTrang: "SanSang", sach: s9)
        let bs9_2 = BanSaoSach(maDinhDanh: "QGL-002", viTriKe: "Kệ B1-05", tinhTrang: "SanSang", sach: s9)
        [bs9_1, bs9_2].forEach { s9.dsBanSao.append($0); modelContext.insert($0) }
        
        // Sách 10: Kính Vạn Hoa
        let s10 = Sach(
            tenSach: "Kính Vạn Hoa - Tập Đặc Biệt",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Truyện tranh",
            tienCoc: 60000,
            phiMuon: 8000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbKimDong,
            tacGia: tgAnh
        )
        modelContext.insert(s10)
        let bs10_1 = BanSaoSach(maDinhDanh: "KVH-001", viTriKe: "Kệ C2-01", tinhTrang: "SanSang", sach: s10)
        let bs10_2 = BanSaoSach(maDinhDanh: "KVH-002", viTriKe: "Kệ C2-02", tinhTrang: "SanSang", sach: s10)
        [bs10_1, bs10_2].forEach { s10.dsBanSao.append($0); modelContext.insert($0) }
        
        // 5. Đúng 3 Độc giả
        let dg1 = DocGia(
            hoTen: "Trần Quốc Bảo",
            email: "bao.tran@email.com",
            soDienThoai: "0901234567",
            lopKhoa: "CNTT K20",
            loaiThe: "VIP",
            soDuTaiKhoan: 300000
        )
        let dg2 = DocGia(
            hoTen: "Lê Hoàng Yến",
            email: "yen.le@email.com",
            soDienThoai: "0912345678",
            lopKhoa: "Kinh Tế K21",
            loaiThe: "Thuong",
            soDuTaiKhoan: 150000
        )
        let dg3 = DocGia(
            hoTen: "Phạm Minh Tuấn",
            email: "tuan.pham@email.com",
            soDienThoai: "0987654321",
            lopKhoa: "Ngoại Ngữ K19",
            loaiThe: "Thuong",
            soDuTaiKhoan: 80000
        )
        [dg1, dg2, dg3].forEach { modelContext.insert($0) }
        
        // 6. Giao dịch Phiếu Mượn (6 phiếu mượn với số liệu khớp chính xác 100%)
        let now = Date()
        let calendar = Calendar.current
        
        // Phiếu 1: Đang mượn (đúng hạn) - Trần Quốc Bảo (VIP)
        let pm1 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: 13, to: now) ?? now,
            tienCocThucTe: 0, // VIP miễn cọc
            phiMuonThucTe: 15000,
            phuongThucThanhToan: "TaiKhoan",
            banSao: bs1_2,
            docGia: dg1
        )
        
        // Phiếu 2: Đang mượn (QUÁ HẠN 4 NGÀY) - Lê Hoàng Yến
        let pm2 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -18, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
            tienCocThucTe: 200000, // Cọc đang giữ
            phiMuonThucTe: 30000,
            phuongThucThanhToan: "TienMat",
            banSao: bs2_1,
            docGia: dg2
        )
        
        // Phiếu 3: Đang mượn (đúng hạn) - Phạm Minh Tuấn
        let pm3 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: 11, to: now) ?? now,
            tienCocThucTe: 50000, // Cọc đang giữ
            phiMuonThucTe: 5000,
            phuongThucThanhToan: "TienMat",
            banSao: bs3_1,
            docGia: dg3
        )
        
        // Phiếu 4: Đã trả đúng hạn - Trần Quốc Bảo (VIP)
        let pm4 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: 9, to: now) ?? now,
            ngayTra: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            tienCocThucTe: 0,
            phiMuonThucTe: 5000,
            soNgayTre: 0,
            tienPhat: 0,
            phuongThucThanhToan: "TaiKhoan",
            phuongThucHoanTien: "TaiKhoan",
            banSao: bs4_1,
            docGia: dg1
        )
        
        // Phiếu 5: Đã trả (TRỄ 3 NGÀY - THU PHẠT 15.000đ) - Lê Hoàng Yến
        let pm5 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -25, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: -11, to: now) ?? now,
            ngayTra: calendar.date(byAdding: .day, value: -8, to: now) ?? now,
            tienCocThucTe: 60000,
            phiMuonThucTe: 8000,
            soNgayTre: 3,
            tienPhat: 15000, // 3 ngày x 5.000đ/ngày
            phuongThucThanhToan: "TienMat",
            phuongThucHoanTien: "TienMat",
            banSao: bs5_1,
            docGia: dg2
        )
        
        // Phiếu 6: Đã trả đúng hạn - Trần Quốc Bảo (VIP)
        let pm6 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: 12, to: now) ?? now,
            ngayTra: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            tienCocThucTe: 0,
            phiMuonThucTe: 15000,
            soNgayTre: 0,
            tienPhat: 0,
            phuongThucThanhToan: "TaiKhoan",
            phuongThucHoanTien: "TaiKhoan",
            banSao: bs7_1,
            docGia: dg1
        )
        
        [pm1, pm2, pm3, pm4, pm5, pm6].forEach { modelContext.insert($0) }
        
        try? modelContext.save()
    }
}