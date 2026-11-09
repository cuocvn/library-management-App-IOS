//
//  DashboardView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries
    @Query private var tatCaSach: [Sach]
    @Query private var tatCaDocGia: [DocGia]
    @Query private var tatCaPhieuMuon: [PhieuMuon]
    
    @State private var timeRange: String = "Tuần này"
    
    // KPI Calculations
    private var tongLuotMuon: Int {
        tatCaPhieuMuon.count
    }
    
    private var doanhThuPhiMuon: Int {
        tatCaPhieuMuon.reduce(0) { $0 + $1.phiMuonThucTe }
    }
    
    private var tienCocDangGiu: Int {
        // Chỉ tính những phiếu chưa trả
        tatCaPhieuMuon.filter { $0.ngayTra == nil }.reduce(0) { $0 + $1.tienCocThucTe }
    }
    
    private var tienPhatDaThu: Int {
        tatCaPhieuMuon.compactMap { $0.tienPhat }.reduce(0, +)
    }
    
    // Data cho biểu đồ tuần (Mock dữ liệu 7 ngày gần nhất dựa trên phiếu mượn)
    private var chartData: [WeeklyBorrowData] {
        let calendar = Calendar.current
        var result: [WeeklyBorrowData] = []
        let weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
        
        for (index, dayName) in weekdays.enumerated() {
            // Đếm số lượng mượn giả lập theo ngày
            let count = tatCaPhieuMuon.filter {
                let dayOfWeek = (calendar.component(.weekday, from: $0.ngayMuon) + 5) % 7
                return dayOfWeek == index
            }.count
            result.append(WeeklyBorrowData(day: dayName, count: max(count, (index + 2) % 5 + 1)))
        }
        return result
    }
    
    // Top 10 Độc giả mượn nhiều nhất
    private var topDocGia: [(docGia: DocGia, soLuot: Int)] {
        var counts: [UUID: Int] = [:]
        for phieu in tatCaPhieuMuon {
            if let dg = phieu.docGia {
                counts[dg.maDocGia, default: 0] += 1
            }
        }
        return tatCaDocGia.map { dg in
            (docGia: dg, soLuot: counts[dg.maDocGia, default: 0])
        }
        .sorted { $0.soLuot > $1.soLuot }
        .prefix(10)
        .map { $0 }
    }
    
    // Top Tác giả được quan tâm nhất
    private var topTacGia: [(tenTacGia: String, soLuot: Int)] {
        var counts: [String: Int] = [:]
        for phieu in tatCaPhieuMuon {
            if let tenTG = phieu.banSao?.sach?.tacGia?.tenTacGia {
                counts[tenTG, default: 0] += 1
            }
        }
        return counts.map { (tenTacGia: $0.key, soLuot: $0.value) }
            .sorted { $0.soLuot > $1.soLuot }
            .prefix(10)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header Chào mừng
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tổng Quan Thư Viện")
                                .font(.title2.weight(.bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Theo dõi hoạt động mượn trả & tài chính")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "books.vertical.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.horizontal)
                    
                    // Lưới 4 Thẻ KPI Tài Chính & Hoạt Động
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        KPICard(
                            title: "Tổng lượt mượn",
                            value: "\(tongLuotMuon)",
                            subtitle: "Tất cả giao dịch",
                            icon: "book.fill",
                            color: AppTheme.primary
                        )
                        KPICard(
                            title: "Doanh thu phí",
                            value: AppTheme.formatVND(doanhThuPhiMuon),
                            subtitle: "Phí thuê sách",
                            icon: "dollarsign.circle.fill",
                            color: AppTheme.warning
                        )
                        KPICard(
                            title: "Tiền cọc đang giữ",
                            value: AppTheme.formatVND(tienCocDangGiu),
                            subtitle: "Sách chưa trả",
                            icon: "shield.lefthalf.filled",
                            color: AppTheme.primaryLight
                        )
                        KPICard(
                            title: "Phạt đã thu",
                            value: AppTheme.formatVND(tienPhatDaThu),
                            subtitle: "Quá hạn bồi hoàn",
                            icon: "exclamationmark.triangle.fill",
                            color: AppTheme.danger
                        )
                    }
                    .padding(.horizontal)
                    
                    // Biểu đồ Apple Charts theo tuần
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Lượt mượn trong tuần", systemImage: "chart.bar.xaxis")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        
                        Chart(chartData) { item in
                            BarMark(
                                x: .value("Ngày", item.day),
                                y: .value("Lượt mượn", item.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.primaryLight],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(6)
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding(16)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    
                    // Top 10 Độc giả mượn nhiều nhất
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Top Độc Giả Tích Cực", systemImage: "person.3.fill")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        
                        if topDocGia.isEmpty {
                            Text("Chưa có dữ liệu độc giả mượn sách")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(Array(topDocGia.enumerated()), id: \.element.docGia.maDocGia) { index, item in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(index < 3 ? AppTheme.primary : AppTheme.textSecondary)
                                        .frame(width: 24, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(item.docGia.hoTen)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            if item.docGia.isVIP {
                                                Text("VIP")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.yellow.opacity(0.2))
                                                    .foregroundColor(.orange)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        Text(item.docGia.lopKhoa.isEmpty ? "Độc giả ngoài" : item.docGia.lopKhoa)
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(item.soLuot) lượt")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(AppTheme.primary)
                                }
                                if index < topDocGia.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    
                    // Top 10 Tác giả
                    if !topTacGia.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Top Tác Giả Được Đọc Nhiều", systemImage: "pencil.and.outline")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            ForEach(Array(topTacGia.enumerated()), id: \.element.tenTacGia) { index, item in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(AppTheme.textSecondary)
                                        .frame(width: 24, alignment: .leading)
                                    Text(item.tenTacGia)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Text("\(item.soLuot) cuốn")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                if index < topTacGia.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(16)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.vertical)
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .navigationTitle("Trang Chủ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Model phụ trợ cho biểu đồ
struct WeeklyBorrowData: Identifiable {
    var id: String { day }
    let day: String
    let count: Int
}

// Widget Thẻ KPI
struct KPICard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
                    .padding(8)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }
}
