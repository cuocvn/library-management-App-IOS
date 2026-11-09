//
//  SampleDataService.swift
//  ThuVienIOS
//
//  MÔ TẢ: Dịch vụ nạp dữ liệu mẫu và đặt lại ứng dụng (Demo / Easter Egg)
//  - Nạp 10 đầu sách chuẩn, 3 độc giả, 6 phiếu mượn khớp số liệu tài chính 100%.
//  - Nguyên tắc thông minh: Khi nạp dữ liệu mẫu, nếu trong app ĐÃ CÓ dữ liệu từ trước
//    thì dữ liệu mẫu sẽ được thêm vào mà VẪN GIỮ NGUYÊN các dữ liệu cũ của người dùng.
//  - Chỉ xóa sạch hoàn toàn khi bấm nút "Xóa Sạch Dữ Liệu" trong Cài Đặt.
//

import Foundation
import SwiftData

@MainActor
final class SampleDataService {
    
    // Xóa sạch toàn bộ dữ liệu trong cơ sở dữ liệu để đưa về trạng thái trắng (Reset)
    // Phục vụ khi người dùng muốn đưa App về trạng thái ban đầu để chuẩn bị demo trước hội đồng
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
    
    // Nạp dữ liệu mẫu chuẩn: 10 Sách, 3 Độc giả, và 6 phiếu mượn khớp số liệu
    // NGUYÊN TẮC: Bổ sung dữ liệu mẫu vào cơ sở dữ liệu hiện có mà KHÔNG xóa mất dữ liệu người dùng đã tạo!
    static func napDuLieuChuan10Sach(modelContext: ModelContext) {
        // Lấy danh sách các đối tượng hiện có để tái sử dụng hoặc tránh trùng lặp
        var dsTheLoai = (try? modelContext.fetch(FetchDescriptor<TheLoai>())) ?? []
        var dsNXB = (try? modelContext.fetch(FetchDescriptor<NhaXuatBan>())) ?? []
        var dsTacGia = (try? modelContext.fetch(FetchDescriptor<TacGia>())) ?? []
        var dsSach = (try? modelContext.fetch(FetchDescriptor<Sach>())) ?? []
        var dsBanSao = (try? modelContext.fetch(FetchDescriptor<BanSaoSach>())) ?? []
        var dsDocGia = (try? modelContext.fetch(FetchDescriptor<DocGia>())) ?? []
        let dsPhieuMuon = (try? modelContext.fetch(FetchDescriptor<PhieuMuon>())) ?? []
        
        // 1. Hàm lấy hoặc tạo Thể loại (không trùng tên)
        func layHoacTaoTheLoai(_ ten: String) -> TheLoai {
            if let tonTai = dsTheLoai.first(where: { $0.tenTheLoai.caseInsensitiveCompare(ten) == .orderedSame }) {
                return tonTai
            }
            let moi = TheLoai(tenTheLoai: ten)
            modelContext.insert(moi)
            dsTheLoai.append(moi)
            return moi
        }
        
        // 2. Hàm lấy hoặc tạo Nhà xuất bản (không trùng tên)
        func layHoacTaoNXB(_ ten: String) -> NhaXuatBan {
            if let tonTai = dsNXB.first(where: { $0.tenNXB.caseInsensitiveCompare(ten) == .orderedSame }) {
                return tonTai
            }
            let moi = NhaXuatBan(tenNXB: ten)
            modelContext.insert(moi)
            dsNXB.append(moi)
            return moi
        }
        
        // 3. Hàm lấy hoặc tạo Tác giả (không trùng tên)
        func layHoacTaoTacGia(_ ten: String) -> TacGia {
            if let tonTai = dsTacGia.first(where: { $0.tenTacGia.caseInsensitiveCompare(ten) == .orderedSame }) {
                return tonTai
            }
            let moi = TacGia(tenTacGia: ten)
            modelContext.insert(moi)
            dsTacGia.append(moi)
            return moi
        }
        
        // Khởi tạo các Thể loại mẫu
        let tlCNTT = layHoacTaoTheLoai("Công nghệ thông tin")
        let tlKinhTe = layHoacTaoTheLoai("Kinh tế & Đầu tư")
        let tlKyNang = layHoacTaoTheLoai("Kỹ năng & Phát triển")
        let tlVanHoc = layHoacTaoTheLoai("Văn học & Nghệ thuật")
        
        // Khởi tạo các NXB mẫu
        let nxbKHTN = layHoacTaoNXB("NXB Khoa Học & Kỹ Thuật")
        let nxbTre = layHoacTaoNXB("NXB Trẻ")
        let nxbLaoDong = layHoacTaoNXB("NXB Lao Động - Xã Hội")
        let nxbKimDong = layHoacTaoNXB("NXB Kim Đồng")
        
        // Khởi tạo các Tác giả mẫu
        let tgUncleBob = layHoacTaoTacGia("Robert C. Martin")
        let tgPaul = layHoacTaoTacGia("Paul Hudson")
        let tgCarnegie = layHoacTaoTacGia("Dale Carnegie")
        let tgHousel = layHoacTaoTacGia("Morgan Housel")
        let tgAnh = layHoacTaoTacGia("Nguyễn Nhật Ánh")
        
        // 4. Hàm lấy hoặc thêm Đầu Sách mẫu và Bản sao vật lý
        func themSachMau(
            tenSach: String,
            namXuatBan: Int,
            phanLoaiGiaTri: String,
            tienCoc: Double,
            phiMuon: Double,
            theLoai: TheLoai,
            nhaXuatBan: NhaXuatBan,
            tacGia: TacGia,
            cacBanSao: [(ma: String, ke: String, tinhTrang: String)]
        ) -> (Sach, [BanSaoSach]) {
            let sach: Sach
            if let daCo = dsSach.first(where: { $0.tenSach == tenSach }) {
                sach = daCo
            } else {
                sach = Sach(
                    tenSach: tenSach,
                    namXuatBan: namXuatBan,
                    phanLoaiGiaTri: phanLoaiGiaTri,
                    tienCoc: tienCoc,
                    phiMuon: phiMuon,
                    theLoai: theLoai,
                    nhaXuatBan: nhaXuatBan,
                    tacGia: tacGia
                )
                modelContext.insert(sach)
                dsSach.append(sach)
            }
            
            var ketQuaBanSao: [BanSaoSach] = []
            for item in cacBanSao {
                if let bsDaCo = dsBanSao.first(where: { $0.maDinhDanh == item.ma }) {
                    ketQuaBanSao.append(bsDaCo)
                } else {
                    let bsMoi = BanSaoSach(
                        maDinhDanh: item.ma,
                        viTriKe: item.ke,
                        tinhTrang: item.tinhTrang,
                        sach: sach
                    )
                    modelContext.insert(bsMoi)
                    dsBanSao.append(bsMoi)
                    if !sach.dsBanSao.contains(where: { $0.maDinhDanh == item.ma }) {
                        sach.dsBanSao.append(bsMoi)
                    }
                    ketQuaBanSao.append(bsMoi)
                }
            }
            return (sach, ketQuaBanSao)
        }
        
        // 10 Đầu Sách Mẫu Chuẩn
        let (_, bs1) = themSachMau(
            tenSach: "Clean Code - Nghệ thuật viết code sạch",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 120000,
            phiMuon: 15000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgUncleBob,
            cacBanSao: [("CC-001", "Kệ A1-01", "SanSang"), ("CC-002", "Kệ A1-02", "DangMuon")]
        )
        
        let (_, bs2) = themSachMau(
            tenSach: "Lập trình iOS với SwiftUI & SwiftData",
            namXuatBan: 2024,
            phanLoaiGiaTri: "Sách quý",
            tienCoc: 200000,
            phiMuon: 30000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgPaul,
            cacBanSao: [("SW-001", "Kệ A2-01", "DangMuon"), ("SW-002", "Kệ A2-02", "SanSang")]
        )
        
        let (_, bs3) = themSachMau(
            tenSach: "Đắc Nhân Tâm (How to Win Friends)",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKyNang,
            nhaXuatBan: nxbTre,
            tacGia: tgCarnegie,
            cacBanSao: [("DNT-001", "Kệ B1-01", "DangMuon"), ("DNT-002", "Kệ B1-02", "SanSang"), ("DNT-003", "Kệ B1-03", "SanSang")]
        )
        
        let (_, bs4) = themSachMau(
            tenSach: "Tâm Lý Học Về Tiền (The Psychology of Money)",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKinhTe,
            nhaXuatBan: nxbLaoDong,
            tacGia: tgHousel,
            cacBanSao: [("TLT-001", "Kệ B2-01", "SanSang"), ("TLT-002", "Kệ B2-02", "SanSang")]
        )
        
        let (_, bs5) = themSachMau(
            tenSach: "Mắt Biếc",
            namXuatBan: 2021,
            phanLoaiGiaTri: "Truyện tranh",
            tienCoc: 60000,
            phiMuon: 8000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbTre,
            tacGia: tgAnh,
            cacBanSao: [("MB-001", "Kệ C1-01", "SanSang"), ("MB-002", "Kệ C1-02", "SanSang")]
        )
        
        let (_, _) = themSachMau(
            tenSach: "Cho Tôi Xin Một Vé Đi Tuổi Thơ",
            namXuatBan: 2020,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbTre,
            tacGia: tgAnh,
            cacBanSao: [("VTT-001", "Kệ C1-03", "SanSang"), ("VTT-002", "Kệ C1-04", "SanSang")]
        )
        
        let (_, bs7) = themSachMau(
            tenSach: "Clean Architecture - Kiến trúc phần mềm sạch",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Giáo trình",
            tienCoc: 120000,
            phiMuon: 15000,
            theLoai: tlCNTT,
            nhaXuatBan: nxbKHTN,
            tacGia: tgUncleBob,
            cacBanSao: [("CA-001", "Kệ A1-04", "SanSang"), ("CA-002", "Kệ A1-05", "SanSang")]
        )
        
        let (_, _) = themSachMau(
            tenSach: "Khởi Nghiệp Tinh Gọn (The Lean Startup)",
            namXuatBan: 2021,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKinhTe,
            nhaXuatBan: nxbLaoDong,
            tacGia: tgHousel,
            cacBanSao: [("LS-001", "Kệ B2-03", "SanSang"), ("LS-002", "Kệ B2-04", "SanSang")]
        )
        
        let (_, _) = themSachMau(
            tenSach: "Quẳng Gánh Lo Đi Và Vui Sống",
            namXuatBan: 2022,
            phanLoaiGiaTri: "Sách thường",
            tienCoc: 50000,
            phiMuon: 5000,
            theLoai: tlKyNang,
            nhaXuatBan: nxbTre,
            tacGia: tgCarnegie,
            cacBanSao: [("QGL-001", "Kệ B1-04", "SanSang"), ("QGL-002", "Kệ B1-05", "SanSang")]
        )
        
        let (_, _) = themSachMau(
            tenSach: "Kính Vạn Hoa - Tập Đặc Biệt",
            namXuatBan: 2023,
            phanLoaiGiaTri: "Truyện tranh",
            tienCoc: 60000,
            phiMuon: 8000,
            theLoai: tlVanHoc,
            nhaXuatBan: nxbKimDong,
            tacGia: tgAnh,
            cacBanSao: [("KVH-001", "Kệ C2-01", "SanSang"), ("KVH-002", "Kệ C2-02", "SanSang")]
        )
        
        // 5. Hàm lấy hoặc thêm Độc Giả mẫu
        func layHoacTaoDocGia(hoTen: String, email: String, sdt: String, lop: String, loaiThe: String, soDu: Double) -> DocGia {
            if let daCo = dsDocGia.first(where: { $0.hoTen == hoTen }) {
                return daCo
            }
            let moi = DocGia(hoTen: hoTen, email: email, soDienThoai: sdt, lopKhoa: lop, loaiThe: loaiThe, soDuTaiKhoan: soDu)
            modelContext.insert(moi)
            dsDocGia.append(moi)
            return moi
        }
        
        let dg1 = layHoacTaoDocGia(hoTen: "Trần Quốc Bảo", email: "bao.tran@email.com", sdt: "0901234567", lop: "CNTT K20", loaiThe: "VIP", soDu: 300000)
        let dg2 = layHoacTaoDocGia(hoTen: "Lê Hoàng Yến", email: "yen.le@email.com", sdt: "0912345678", lop: "Kinh Tế K21", loaiThe: "Thuong", soDu: 150000)
        let dg3 = layHoacTaoDocGia(hoTen: "Phạm Minh Tuấn", email: "tuan.pham@email.com", sdt: "0987654321", lop: "Ngoại Ngữ K19", loaiThe: "Thuong", soDu: 80000)
        
        // 6. Hàm thêm Phiếu Mượn mẫu (chỉ thêm nếu chưa có)
        let now = Date()
        let calendar = Calendar.current
        
        func themPhieuMuon(
            banSao: BanSaoSach?,
            docGia: DocGia?,
            ngayMuonOffset: Int,
            hanTraOffset: Int,
            ngayTraOffset: Int?,
            tienCoc: Double,
            phiMuon: Double,
            soNgayTre: Int = 0,
            tienPhat: Double = 0,
            ptThanhToan: String,
            ptHoanTien: String? = nil
        ) {
            guard let bs = banSao, let dg = docGia else { return }
            let daTonTai = dsPhieuMuon.contains(where: {
                $0.banSao?.maDinhDanh == bs.maDinhDanh && $0.docGia?.hoTen == dg.hoTen && $0.phiMuonThucTe == phiMuon
            })
            if daTonTai { return }
            
            let ngayMuon = calendar.date(byAdding: .day, value: ngayMuonOffset, to: now) ?? now
            let hanTra = calendar.date(byAdding: .day, value: hanTraOffset, to: now) ?? now
            let ngayTra = ngayTraOffset != nil ? (calendar.date(byAdding: .day, value: ngayTraOffset!, to: now) ?? now) : nil
            
            let pm = PhieuMuon(
                ngayMuon: ngayMuon,
                hanTra: hanTra,
                ngayTra: ngayTra,
                tienCocThucTe: tienCoc,
                phiMuonThucTe: phiMuon,
                soNgayTre: soNgayTre,
                tienPhat: tienPhat,
                phuongThucThanhToan: ptThanhToan,
                phuongThucHoanTien: ptHoanTien,
                banSao: bs,
                docGia: dg
            )
            modelContext.insert(pm)
        }
        
        // Phiếu 1: Đang mượn (đúng hạn) - Trần Quốc Bảo (VIP)
        let bsCC002 = bs1.first(where: { $0.maDinhDanh == "CC-002" })
        themPhieuMuon(banSao: bsCC002, docGia: dg1, ngayMuonOffset: -1, hanTraOffset: 13, ngayTraOffset: nil, tienCoc: 0, phiMuon: 15000, ptThanhToan: "TaiKhoan")
        
        // Phiếu 2: Đang mượn (QUÁ HẠN 4 NGÀY) - Lê Hoàng Yến
        let bsSW001 = bs2.first(where: { $0.maDinhDanh == "SW-001" })
        themPhieuMuon(banSao: bsSW001, docGia: dg2, ngayMuonOffset: -18, hanTraOffset: -4, ngayTraOffset: nil, tienCoc: 200000, phiMuon: 30000, ptThanhToan: "TienMat")
        
        // Phiếu 3: Đang mượn (đúng hạn) - Phạm Minh Tuấn
        let bsDNT001 = bs3.first(where: { $0.maDinhDanh == "DNT-001" })
        themPhieuMuon(banSao: bsDNT001, docGia: dg3, ngayMuonOffset: -3, hanTraOffset: 11, ngayTraOffset: nil, tienCoc: 50000, phiMuon: 5000, ptThanhToan: "TienMat")
        
        // Phiếu 4: Đã trả đúng hạn - Trần Quốc Bảo (VIP)
        let bsTLT001 = bs4.first(where: { $0.maDinhDanh == "TLT-001" })
        themPhieuMuon(banSao: bsTLT001, docGia: dg1, ngayMuonOffset: -5, hanTraOffset: 9, ngayTraOffset: -1, tienCoc: 0, phiMuon: 5000, ptThanhToan: "TaiKhoan", ptHoanTien: "TaiKhoan")
        
        // Phiếu 5: Đã trả (TRỄ 3 NGÀY - THU PHẠT 15.000đ) - Lê Hoàng Yến
        let bsMB001 = bs5.first(where: { $0.maDinhDanh == "MB-001" })
        themPhieuMuon(banSao: bsMB001, docGia: dg2, ngayMuonOffset: -25, hanTraOffset: -11, ngayTraOffset: -8, tienCoc: 60000, phiMuon: 8000, soNgayTre: 3, tienPhat: 15000, ptThanhToan: "TienMat", ptHoanTien: "TienMat")
        
        // Phiếu 6: Đã trả đúng hạn - Trần Quốc Bảo (VIP)
        let bsCA001 = bs7.first(where: { $0.maDinhDanh == "CA-001" })
        themPhieuMuon(banSao: bsCA001, docGia: dg1, ngayMuonOffset: -2, hanTraOffset: 12, ngayTraOffset: -1, tienCoc: 0, phiMuon: 15000, ptThanhToan: "TaiKhoan", ptHoanTien: "TaiKhoan")
        
        try? modelContext.save()
    }
}
