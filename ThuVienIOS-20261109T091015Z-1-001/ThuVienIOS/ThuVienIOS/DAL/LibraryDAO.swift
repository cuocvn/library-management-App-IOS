//
//  LibraryDAO.swift
//  ThuVienIOS
//
//  MÔ TẢ: Chương 3 - Tầng Truy Xuất Cơ Sở Dữ Liệu: Database Access Layer (DAL / DAO)
//  GIẢNG VIÊN: Tiêu Kim Cương - Lập trình Di động trên iOS
//

import Foundation
import UIKit

// MARK: - Database Access Layer (DAL)
final class LibraryDAO {
    
    // Singleton pattern cho Data Access Object
    static let shared = LibraryDAO()
    
    // Thuộc tính tham chiếu cơ sở dữ liệu
    private let dataManager = DataManager.shared
    
    private init() {
        initDatabase()
    }
    
    // MARK: - Các API chính theo giáo trình Chương 3
    
    /// 1. Khởi tạo Cơ sở dữ liệu (Slide 13)
    func initDatabase() {
        // Tự động load và khởi tạo cấu trúc dữ liệu nếu chưa tồn tại
        _ = dataManager
    }
    
    /// 2. Mở cơ sở dữ liệu (Slide 15)
    func openDatabase() -> Bool {
        return true
    }
    
    // MARK: - API Truy Xuất Sách (CRUD Sach)
    
    /// Lấy tất cả đầu sách chưa bị xóa mềm
    func getAllSach() -> [Sach] {
        return dataManager.dsSach.filter { !$0.daAn }
    }
    
    /// Ghi một đối tượng Sach vào cơ sở dữ liệu (Slide 16)
    func insertSach(_ sach: Sach) {
        dataManager.themSach(sach)
    }
    
    /// Cập nhật thông tin một đầu sách
    func updateSach(_ sach: Sach) {
        dataManager.save()
    }
    
    /// Xóa bỏ một đầu sách khỏi cơ sở dữ liệu (Slide 19)
    func deleteSach(_ sach: Sach) {
        dataManager.xoaSach(sach)
    }
    
    // MARK: - API Truy Xuất Độc Giả (CRUD DocGia)
    
    func getAllDocGia() -> [DocGia] {
        return dataManager.dsDocGia.filter { !$0.daAn }
    }
    
    func insertDocGia(_ dg: DocGia) {
        dataManager.themDocGia(dg)
    }
    
    func updateDocGia(_ dg: DocGia) {
        dataManager.save()
    }
    
    func deleteDocGia(_ dg: DocGia) {
        dataManager.xoaDocGia(dg)
    }
    
    // MARK: - API Truy Xuất Phiếu Mượn (CRUD PhieuMuon)
    
    func getAllPhieuMuon() -> [PhieuMuon] {
        return dataManager.dsPhieuMuon
    }
    
    func insertPhieuMuon(_ pm: PhieuMuon) {
        dataManager.themPhieuMuon(pm)
    }
    
    func updatePhieuMuon(_ pm: PhieuMuon) {
        dataManager.save()
    }
    
    /// Lưu toàn bộ thay đổi bền vững xuống đĩa
    func saveDatabase() {
        dataManager.save()
    }
}
