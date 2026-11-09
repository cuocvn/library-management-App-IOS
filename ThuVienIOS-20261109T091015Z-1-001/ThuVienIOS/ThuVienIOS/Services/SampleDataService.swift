//
//  SampleDataService.swift
//  ThuVienIOS
//

import Foundation
import SwiftData

@MainActor
final class SampleDataService {
    static func createSampleData(modelContext: ModelContext) {
        // Kiểm tra xem đã có dữ liệu chưa
        var descriptor = FetchDescriptor<Sach>()
        descriptor.fetchLimit = 1
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        if existingCount > 0 {
            return // Đã có dữ liệu thì không seed lại
        }
        
        // 1. Thể loại
        let tlCNTT = TheLoai(tenTheLoai: "Công nghệ thông tin")
        let tlKinhTe = TheLoai(tenTheLoai: "Kinh tế - Khởi nghiệp")
        let tlVanHoc = TheLoai(tenTheLoai: "Văn học & Nghệ thuật")
        let tlKhoaHoc = TheLoai(tenTheLoai: "Khoa học tự nhiên")
        [tlCNTT, tlKinhTe, tlVanHoc, tlKhoaHoc].forEach { modelContext.insert($0) }
        
        // 2. Nhà xuất bản
        let nxbTre = NhaXuatBan(tenNXB: "NXB Trẻ")
        let nxbKimDong = NhaXuatBan(tenNXB: "NXB Kim Đồng")
        let nxbKHTN = NhaXuatBan(tenNXB: "NXB Khoa Học & Kỹ Thuật")
        [nxbTre, nxbKimDong, nxbKHTN].forEach { modelContext.insert($0) }
        
        // 3. Tác giả
        let tgBao = TacGia(tenTacGia: "Trần Quốc Bảo")
        let tgNam = TacGia(tenTacGia: "Nguyễn Nhật Ánh")
        let tgUncleBob = TacGia(tenTacGia: "Robert C. Martin")
        [tgBao, tgNam, tgUncleBob].forEach { modelContext.insert($0) }
        
        // 4. Sách & Bản sao
        let sachCleanCode = Sach(
            tenSach: "Clean Code - Nghệ thuật viết code sạch",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 120000,
            phiMuon: 15000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgUncleBob
        )
        modelContext.insert(sachCleanCode)
        
        let bsCC1 = BanSaoSach(maDinhDanh: "CC-001", viTriKe: "Kệ A1-01", tinhTrang: "SanSang", sach: sachCleanCode)
        let bsCC2 = BanSaoSach(maDinhDanh: "CC-002", viTriKe: "Kệ A1-02", tinhTrang: "SanSang", sach: sachCleanCode)
        let bsCC3 = BanSaoSach(maDinhDanh: "CC-003", viTriKe: "Kệ A1-03", tinhTrang: "DangMuon", sach: sachCleanCode)
        [bsCC1, bsCC2, bsCC3].forEach {
            sachCleanCode.dsBanSao.append($0)
            modelContext.insert($0)
        }
        
        let sachSwiftUI = Sach(
            tenSach: "Lập trình iOS với SwiftUI & SwiftData",
            namXuatBan: 2024,
            phanLoaiGiaTri: "Sách quý",
            tienCoc: 150000,
            phiMuon: 20000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgBao
        )
        modelContext.insert(sachSwiftUI)
        let bsSW1 = BanSaoSach(maDinhDanh: "SW-001", viTriKe: "Kệ A2-01", tinhTrang: "DangMuon", sach: sachSwiftUI)
        let bsSW2 = BanSaoSach(maDinhDanh: "SW-002", viTriKe: "Kệ A2-02", tinhTrang: "SanSang", sach: sachSwiftUI)
        [bsSW1, bsSW2].forEach {
            sachSwiftUI.dsBanSao.append($0)
            modelContext.insert($0)
        }
        
        let sachMatBiec = Sach(
            tenSach: "Mắt Biếc",
            namXuatBan: 2021,
            phanLoaiGiaTri: "Truyện tranh",
            tienCoc: 60000,
            phiMuon: 8000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbTre,
            tacGia: tgNam
        )
        modelContext.insert(sachMatBiec)
        let bsMB1 = BanSaoSach(maDinhDanh: "MB-001", viTriKe: "Kệ B1-01", tinhTrang: "SanSang", sach: sachMatBiec)
        sachMatBiec.dsBanSao.append(bsMB1)
        modelContext.insert(bsMB1)
        
        // 5. Độc giả
        let dg1 = DocGia(
            hoTen: "Trần Quốc Bảo",
            email: "bao.tran@email.com",
            soDienThoai: "0901234567",
            lopKhoa: "CNTT K20",
            loaiThe: "VIP",
            soDuTaiKhoan: 350000
        )
        let dg2 = DocGia(
            hoTen: "Lê Hoàng Yến",
            email: "yen.le@email.com",
            soDienThoai: "0912345678",
            lopKhoa: "Kinh Tế K21",
            loaiThe: "Thuong",
            soDuTaiKhoan: 50000
        )
        let dg3 = DocGia(
            hoTen: "Phạm Minh Tuấn",
            email: "tuan.pham@email.com",
            soDienThoai: "0987654321",
            lopKhoa: "Ngoại Ngữ K19",
            loaiThe: "Thuong",
            soDuTaiKhoan: 0
        )
        [dg1, dg2, dg3].forEach { modelContext.insert($0) }
        
        // 6. Phiếu mượn
        let now = Date()
        let calendar = Calendar.current
        
        // Phiếu 1: Đang mượn (đúng hạn)
        let pm1 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: 11, to: now) ?? now,
            tienCocThucTe: 0, // VIP nên cọc 0
            phiMuonThucTe: 15000,
            phuongThucThanhToan: "TaiKhoan",
            banSao: bsCC3,
            docGia: dg1
        )
        
        // Phiếu 2: Đang mượn nhưng đã Quá Hạn
        let pm2 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -20, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: -6, to: now) ?? now, // Quá hạn 6 ngày
            tienCocThucTe: 150000,
            phiMuonThucTe: 20000,
            phuongThucThanhToan: "TienMat",
            banSao: bsSW1,
            docGia: dg2
        )
        
        // Phiếu 3: Đã trả thành công trong quá khứ
        let pm3 = PhieuMuon(
            ngayMuon: calendar.date(byAdding: .day, value: -30, to: now) ?? now,
            hanTra: calendar.date(byAdding: .day, value: -16, to: now) ?? now,
            ngayTra: calendar.date(byAdding: .day, value: -17, to: now) ?? now, // Trả đúng hạn
            tienCocThucTe: 60000,
            phiMuonThucTe: 8000,
            soNgayTre: 0,
            tienPhat: 0,
            phuongThucThanhToan: "TienMat",
            phuongThucHoanTien: "TienMat",
            banSao: bsMB1,
            docGia: dg3
        )
        
        [pm1, pm2, pm3].forEach { modelContext.insert($0) }
        
        try? modelContext.save()
    }
}
