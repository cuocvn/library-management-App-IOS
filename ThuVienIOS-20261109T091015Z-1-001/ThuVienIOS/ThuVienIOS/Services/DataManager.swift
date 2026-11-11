//
//  DataManager.swift
//  ThuVienIOS
//
//  MÔ TẢ: Quản lý toàn bộ cơ sở dữ liệu và lưu trữ bền vững (Local JSON Store)
//  Tương thích: iOS 16.0+ / Xcode 14.2+ (Thay thế SwiftData)
//

import Foundation
import SwiftUI

@MainActor
final class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var dsTheLoai: [TheLoai] = []
    @Published var dsNXB: [NhaXuatBan] = []
    @Published var dsTacGia: [TacGia] = []
    @Published var dsSach: [Sach] = []
    @Published var dsBanSao: [BanSaoSach] = []
    @Published var dsDocGia: [DocGia] = []
    @Published var dsPhieuMuon: [PhieuMuon] = []
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("library_database_v16.json")
    }
    
    private init() {
        load()
    }
    
    // MARK: - Lưu trữ vào File JSON Bền Vững
    func save() {
        objectWillChange.send()
        let dto = DatabaseDTO(
            theLoai: dsTheLoai.map { DatabaseDTO.TheLoaiDTO(maTheLoai: $0.maTheLoai, tenTheLoai: $0.tenTheLoai) },
            nxb: dsNXB.map { DatabaseDTO.NXBDTO(maNXB: $0.maNXB, tenNXB: $0.tenNXB) },
            tacGia: dsTacGia.map { DatabaseDTO.TacGiaDTO(maTacGia: $0.maTacGia, tenTacGia: $0.tenTacGia) },
            sach: dsSach.map {
                DatabaseDTO.SachDTO(
                    maSach: $0.maSach,
                    tenSach: $0.tenSach,
                    namXuatBan: $0.namXuatBan,
                    phanLoaiGiaTri: $0.phanLoaiGiaTri,
                    tienCoc: $0.tienCoc,
                    phiMuon: $0.phiMuon,
                    daAn: $0.daAn,
                    theLoaiId: $0.theLoai?.maTheLoai,
                    nxbId: $0.nhaXuatBan?.maNXB,
                    tacGiaId: $0.tacGia?.maTacGia
                )
            },
            banSao: dsBanSao.map {
                DatabaseDTO.BanSaoDTO(
                    maDinhDanh: $0.maDinhDanh,
                    viTriKe: $0.viTriKe,
                    tinhTrang: $0.tinhTrang,
                    maSach: $0.sach?.maSach
                )
            },
            docGia: dsDocGia.map {
                DatabaseDTO.DocGiaDTO(
                    maDocGia: $0.maDocGia,
                    hoTen: $0.hoTen,
                    email: $0.email,
                    soDienThoai: $0.soDienThoai,
                    lopKhoa: $0.lopKhoa,
                    loaiThe: $0.loaiThe,
                    soDuTaiKhoan: $0.soDuTaiKhoan,
                    daAn: $0.daAn
                )
            },
            phieuMuon: dsPhieuMuon.map {
                DatabaseDTO.PhieuMuonDTO(
                    maPhieu: $0.maPhieu,
                    ngayMuon: $0.ngayMuon,
                    hanTra: $0.hanTra,
                    ngayTra: $0.ngayTra,
                    tienCocThucTe: $0.tienCocThucTe,
                    phiMuonThucTe: $0.phiMuonThucTe,
                    soNgayTre: $0.soNgayTre,
                    tienPhat: $0.tienPhat,
                    phuongThucThanhToan: $0.phuongThucThanhToan,
                    phuongThucHoanTien: $0.phuongThucHoanTien,
                    ghiChu: $0.ghiChu,
                    daBaoMatSach: $0.daBaoMatSach,
                    maBanSao: $0.banSao?.maDinhDanh,
                    maDocGia: $0.docGia?.maDocGia
                )
            }
        )
        
        do {
            let data = try JSONEncoder().encode(dto)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Lỗi lưu dữ liệu: \(error)")
        }
    }
    
    // MARK: - Tải dữ liệu từ File JSON
    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Lần đầu mở app: tự động nạp dữ liệu mẫu
            SampleDataService.napDuLieuChuan10Sach(dataManager: self)
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let dto = try JSONDecoder().decode(DatabaseDTO.self, from: data)
            
            // 1. Khôi phục các danh mục
            let mapTL = Dictionary(uniqueKeysWithValues: dto.theLoai.map { ($0.maTheLoai, TheLoai(maTheLoai: $0.maTheLoai, tenTheLoai: $0.tenTheLoai)) })
            let mapNXB = Dictionary(uniqueKeysWithValues: dto.nxb.map { ($0.maNXB, NhaXuatBan(maNXB: $0.maNXB, tenNXB: $0.tenNXB)) })
            let mapTG = Dictionary(uniqueKeysWithValues: dto.tacGia.map { ($0.maTacGia, TacGia(maTacGia: $0.maTacGia, tenTacGia: $0.tenTacGia)) })
            
            self.dsTheLoai = Array(mapTL.values).sorted { $0.tenTheLoai < $1.tenTheLoai }
            self.dsNXB = Array(mapNXB.values).sorted { $0.tenNXB < $1.tenNXB }
            self.dsTacGia = Array(mapTG.values).sorted { $0.tenTacGia < $1.tenTacGia }
            
            // 2. Khôi phục Sách
            var mapSach: [UUID: Sach] = [:]
            for sDTO in dto.sach {
                let sach = Sach(
                    maSach: sDTO.maSach,
                    tenSach: sDTO.tenSach,
                    namXuatBan: sDTO.namXuatBan,
                    phanLoaiGiaTri: sDTO.phanLoaiGiaTri,
                    tienCoc: sDTO.tienCoc,
                    phiMuon: sDTO.phiMuon,
                    daAn: sDTO.daAn,
                    theLoai: sDTO.theLoaiId != nil ? mapTL[sDTO.theLoaiId!] : nil,
                    nhaXuatBan: sDTO.nxbId != nil ? mapNXB[sDTO.nxbId!] : nil,
                    tacGia: sDTO.tacGiaId != nil ? mapTG[sDTO.tacGiaId!] : nil
                )
                mapSach[sDTO.maSach] = sach
                sach.theLoai?.dsSach.append(sach)
                sach.nhaXuatBan?.dsSach.append(sach)
                sach.tacGia?.dsSach.append(sach)
            }
            self.dsSach = Array(mapSach.values)
            
            // 3. Khôi phục Bản sao vật lý
            var mapBanSao: [String: BanSaoSach] = [:]
            for bsDTO in dto.banSao {
                let bs = BanSaoSach(
                    maDinhDanh: bsDTO.maDinhDanh,
                    viTriKe: bsDTO.viTriKe,
                    tinhTrang: bsDTO.tinhTrang,
                    sach: bsDTO.maSach != nil ? mapSach[bsDTO.maSach!] : nil
                )
                mapBanSao[bsDTO.maDinhDanh] = bs
                bs.sach?.dsBanSao.append(bs)
            }
            self.dsBanSao = Array(mapBanSao.values)
            
            // 4. Khôi phục Độc giả
            var mapDocGia: [UUID: DocGia] = [:]
            for dgDTO in dto.docGia {
                let dg = DocGia(
                    maDocGia: dgDTO.maDocGia,
                    hoTen: dgDTO.hoTen,
                    email: dgDTO.email,
                    soDienThoai: dgDTO.soDienThoai,
                    lopKhoa: dgDTO.lopKhoa,
                    loaiThe: dgDTO.loaiThe,
                    soDuTaiKhoan: dgDTO.soDuTaiKhoan,
                    daAn: dgDTO.daAn
                )
                mapDocGia[dgDTO.maDocGia] = dg
            }
            self.dsDocGia = Array(mapDocGia.values)
            
            // 5. Khôi phục Phiếu mượn
            var listPM: [PhieuMuon] = []
            for pmDTO in dto.phieuMuon {
                let pm = PhieuMuon(
                    maPhieu: pmDTO.maPhieu,
                    ngayMuon: pmDTO.ngayMuon,
                    hanTra: pmDTO.hanTra,
                    ngayTra: pmDTO.ngayTra,
                    tienCocThucTe: pmDTO.tienCocThucTe,
                    phiMuonThucTe: pmDTO.phiMuonThucTe,
                    soNgayTre: pmDTO.soNgayTre,
                    tienPhat: pmDTO.tienPhat,
                    phuongThucThanhToan: pmDTO.phuongThucThanhToan,
                    phuongThucHoanTien: pmDTO.phuongThucHoanTien,
                    ghiChu: pmDTO.ghiChu,
                    daBaoMatSach: pmDTO.daBaoMatSach,
                    banSao: pmDTO.maBanSao != nil ? mapBanSao[pmDTO.maBanSao!] : nil,
                    docGia: pmDTO.maDocGia != nil ? mapDocGia[pmDTO.maDocGia!] : nil
                )
                listPM.append(pm)
                pm.banSao?.dsPhieuMuon.append(pm)
                pm.docGia?.dsPhieuMuon.append(pm)
            }
            self.dsPhieuMuon = listPM
            
            if dsSach.isEmpty {
                SampleDataService.napDuLieuChuan10Sach(dataManager: self)
            }
        } catch {
            print("Lỗi giải mã dữ liệu: \(error)")
            SampleDataService.napDuLieuChuan10Sach(dataManager: self)
        }
    }
    
    // MARK: - Nghiệp vụ Thêm / Xóa Các Đối Tượng
    func themSach(_ sach: Sach) {
        if !dsSach.contains(where: { $0.maSach == sach.maSach }) {
            dsSach.append(sach)
            sach.theLoai?.dsSach.append(sach)
            sach.nhaXuatBan?.dsSach.append(sach)
            sach.tacGia?.dsSach.append(sach)
        }
        for bs in sach.dsBanSao {
            themBanSao(bs)
        }
        save()
    }
    
    func xoaSach(_ sach: Sach) {
        sach.daAn = true
        save()
    }
    
    func themBanSao(_ bs: BanSaoSach) {
        if !dsBanSao.contains(where: { $0.maDinhDanh == bs.maDinhDanh }) {
            dsBanSao.append(bs)
        }
        if let s = bs.sach, !s.dsBanSao.contains(where: { $0.maDinhDanh == bs.maDinhDanh }) {
            s.dsBanSao.append(bs)
        }
        save()
    }
    
    func themDocGia(_ dg: DocGia) {
        if !dsDocGia.contains(where: { $0.maDocGia == dg.maDocGia }) {
            dsDocGia.append(dg)
        }
        save()
    }
    
    func xoaDocGia(_ dg: DocGia) {
        dg.daAn = true
        save()
    }
    
    func themPhieuMuon(_ pm: PhieuMuon) {
        if !dsPhieuMuon.contains(where: { $0.maPhieu == pm.maPhieu }) {
            dsPhieuMuon.append(pm)
        }
        if let bs = pm.banSao, !bs.dsPhieuMuon.contains(where: { $0.maPhieu == pm.maPhieu }) {
            bs.dsPhieuMuon.append(pm)
        }
        if let dg = pm.docGia, !dg.dsPhieuMuon.contains(where: { $0.maPhieu == pm.maPhieu }) {
            dg.dsPhieuMuon.append(pm)
        }
        save()
    }
    
    func themTheLoai(_ tl: TheLoai) {
        if !dsTheLoai.contains(where: { $0.maTheLoai == tl.maTheLoai }) {
            dsTheLoai.append(tl)
            save()
        }
    }
    
    // Tìm hoặc tạo mới Thể loại khi người dùng gõ tên
    func layHoacTaoTheLoai(_ ten: String) -> TheLoai {
        let clean = ten.trimmingCharacters(in: .whitespacesAndNewlines)
        if let tonTai = dsTheLoai.first(where: { $0.tenTheLoai.caseInsensitiveCompare(clean) == .orderedSame }) {
            return tonTai
        }
        let moi = TheLoai(tenTheLoai: clean)
        themTheLoai(moi)
        return moi
    }
    
    func xoaTheLoai(_ tl: TheLoai) {
        dsTheLoai.removeAll { $0.maTheLoai == tl.maTheLoai }
        for s in dsSach where s.theLoai?.maTheLoai == tl.maTheLoai {
            s.theLoai = nil
        }
        save()
    }
    
    func themNXB(_ nxb: NhaXuatBan) {
        if !dsNXB.contains(where: { $0.maNXB == nxb.maNXB }) {
            dsNXB.append(nxb)
            save()
        }
    }
    
    // Tìm hoặc tạo mới NXB khi người dùng gõ tên
    func layHoacTaoNXB(_ ten: String) -> NhaXuatBan {
        let clean = ten.trimmingCharacters(in: .whitespacesAndNewlines)
        if let tonTai = dsNXB.first(where: { $0.tenNXB.caseInsensitiveCompare(clean) == .orderedSame }) {
            return tonTai
        }
        let moi = NhaXuatBan(tenNXB: clean)
        themNXB(moi)
        return moi
    }
    
    func xoaNXB(_ nxb: NhaXuatBan) {
        dsNXB.removeAll { $0.maNXB == nxb.maNXB }
        for s in dsSach where s.nhaXuatBan?.maNXB == nxb.maNXB {
            s.nhaXuatBan = nil
        }
        save()
    }
    
    func themTacGia(_ tg: TacGia) {
        if !dsTacGia.contains(where: { $0.maTacGia == tg.maTacGia }) {
            dsTacGia.append(tg)
            save()
        }
    }
    
    // Tìm hoặc tạo mới Tác giả khi người dùng gõ tên
    func layHoacTaoTacGia(_ ten: String) -> TacGia {
        let clean = ten.trimmingCharacters(in: .whitespacesAndNewlines)
        if let tonTai = dsTacGia.first(where: { $0.tenTacGia.caseInsensitiveCompare(clean) == .orderedSame }) {
            return tonTai
        }
        let moi = TacGia(tenTacGia: clean)
        themTacGia(moi)
        return moi
    }
    
    func xoaTacGia(_ tg: TacGia) {
        dsTacGia.removeAll { $0.maTacGia == tg.maTacGia }
        for s in dsSach where s.tacGia?.maTacGia == tg.maTacGia {
            s.tacGia = nil
        }
        save()
    }
    
    func xoaToanBoDuLieu() {
        dsPhieuMuon.removeAll()
        dsBanSao.removeAll()
        dsSach.removeAll()
        dsDocGia.removeAll()
        dsTheLoai.removeAll()
        dsNXB.removeAll()
        dsTacGia.removeAll()
        save()
    }
    
    func napDuLieuMau() {
        SampleDataService.napDuLieuChuan10Sach(dataManager: self)
    }
}

// MARK: - DTO Serialization Structs
private struct DatabaseDTO: Codable {
    struct TheLoaiDTO: Codable {
        var maTheLoai: UUID
        var tenTheLoai: String
    }
    struct NXBDTO: Codable {
        var maNXB: UUID
        var tenNXB: String
    }
    struct TacGiaDTO: Codable {
        var maTacGia: UUID
        var tenTacGia: String
    }
    struct SachDTO: Codable {
        var maSach: UUID
        var tenSach: String
        var namXuatBan: Int
        var phanLoaiGiaTri: String
        var tienCoc: Int
        var phiMuon: Int
        var daAn: Bool
        var theLoaiId: UUID?
        var nxbId: UUID?
        var tacGiaId: UUID?
    }
    struct BanSaoDTO: Codable {
        var maDinhDanh: String
        var viTriKe: String
        var tinhTrang: String
        var maSach: UUID?
    }
    struct DocGiaDTO: Codable {
        var maDocGia: UUID
        var hoTen: String
        var email: String
        var soDienThoai: String
        var lopKhoa: String
        var loaiThe: String
        var soDuTaiKhoan: Int
        var daAn: Bool
    }
    struct PhieuMuonDTO: Codable {
        var maPhieu: UUID
        var ngayMuon: Date
        var hanTra: Date
        var ngayTra: Date?
        var tienCocThucTe: Int
        var phiMuonThucTe: Int
        var soNgayTre: Int?
        var tienPhat: Int?
        var phuongThucThanhToan: String?
        var phuongThucHoanTien: String?
        var ghiChu: String?
        var daBaoMatSach: Bool
        var maBanSao: String?
        var maDocGia: UUID?
    }
    
    var theLoai: [TheLoaiDTO]
    var nxb: [NXBDTO]
    var tacGia: [TacGiaDTO]
    var sach: [SachDTO]
    var banSao: [BanSaoDTO]
    var docGia: [DocGiaDTO]
    var phieuMuon: [PhieuMuonDTO]
}
