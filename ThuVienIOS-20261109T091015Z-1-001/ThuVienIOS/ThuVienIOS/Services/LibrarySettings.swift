//
//  LibrarySettings.swift
//  ThuVienIOS
//

import SwiftUI

final class LibrarySettings: ObservableObject {
    static let shared = LibrarySettings()
    
    @AppStorage("tenThuVien") var tenThuVien: String = "Thư Viện Số iOS"
    @AppStorage("soNgayMuonMacDinh") var soNgayMuonMacDinh: Int = 14
    @AppStorage("mucPhatMoiNgay") var mucPhatMoiNgay: Int = 5000 // VNĐ/ngày
    @AppStorage("mucCocMacDinh") var mucCocMacDinh: Int = 50000 // VNĐ
    @AppStorage("phiMuonMacDinh") var phiMuonMacDinh: Int = 10000 // VNĐ
    
    private init() {}
}
