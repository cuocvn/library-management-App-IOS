//
//  DashboardViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Tab 1 - Màn hình Trang Chủ / Dashboard thống kê
//  CÔNG NGHỆ: UIKit, Storyboard, Auto Layout, Custom Bar Chart
//

import UIKit

class DashboardViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let refreshControl = UIRefreshControl()

    // 4 Thẻ KPI
    private let kpiLuotMuon = KPICardView(title: "Tổng lượt mượn", icon: "arrow.left.arrow.right", color: .appPrimary)
    private let kpiDoanhThu = KPICardView(title: "Doanh thu phí", icon: "banknote.fill", color: .appWarning)
    private let kpiTienCoc = KPICardView(title: "Cọc đang giữ", icon: "shield.fill", color: .systemBlue)
    private let kpiTienPhat = KPICardView(title: "Phạt đã thu", icon: "exclamationmark.triangle.fill", color: .appDanger)

    // Khối biểu đồ
    private let chartCard = UIView()
    private let chartStack = UIStackView()
    private let chartTitleLabel = UILabel()

    // Khối Top 10 Độc Giả
    private let topDocGiaCard = UIView()
    private let topDocGiaStack = UIStackView()

    // Khối Top 10 Tác Giả
    private let topTacGiaCard = UIView()
    private let topTacGiaStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trang Chủ"
        view.backgroundColor = .appBackground
        
        setupNavigation()
        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - Setup Navigation
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Trang Chủ"
    }

    // MARK: - Setup UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        view.addSubview(scrollView)

        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // 1. Grid 4 thẻ KPI (2 hàng x 2 cột)
        let kpiRow1 = UIStackView(arrangedSubviews: [kpiLuotMuon, kpiDoanhThu])
        kpiRow1.axis = .horizontal
        kpiRow1.distribution = .fillEqually
        kpiRow1.spacing = 12

        let kpiRow2 = UIStackView(arrangedSubviews: [kpiTienCoc, kpiTienPhat])
        kpiRow2.axis = .horizontal
        kpiRow2.distribution = .fillEqually
        kpiRow2.spacing = 12

        let kpiContainer = UIStackView(arrangedSubviews: [kpiRow1, kpiRow2])
        kpiContainer.axis = .vertical
        kpiContainer.spacing = 12
        contentView.addArrangedSubview(kpiContainer)

        // 2. Thẻ Biểu Đồ Tuần
        setupChartCard()
        contentView.addArrangedSubview(chartCard)

        // 3. Thẻ Top 10 Độc Giả
        setupTopDocGiaCard()
        contentView.addArrangedSubview(topDocGiaCard)

        // 4. Thẻ Top 10 Tác Giả
        setupTopTacGiaCard()
        contentView.addArrangedSubview(topTacGiaCard)
    }

    private func setupChartCard() {
        AppTheme.applyCardStyle(to: chartCard)
        chartCard.translatesAutoresizingMaskIntoConstraints = false

        let headerLabel = UILabel()
        headerLabel.text = "📊 Lượt mượn 7 ngày gần nhất"
        headerLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headerLabel.textColor = .label

        chartStack.axis = .horizontal
        chartStack.distribution = .fillEqually
        chartStack.alignment = .bottom
        chartStack.spacing = 8
        chartStack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [headerLabel, chartStack])
        container.axis = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        chartCard.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -16),
            chartStack.heightAnchor.constraint(equalToConstant: 130)
        ])
    }

    private func setupTopDocGiaCard() {
        AppTheme.applyCardStyle(to: topDocGiaCard)
        topDocGiaStack.axis = .vertical
        topDocGiaStack.spacing = 10
        topDocGiaStack.translatesAutoresizingMaskIntoConstraints = false
        topDocGiaCard.addSubview(topDocGiaStack)

        NSLayoutConstraint.activate([
            topDocGiaStack.topAnchor.constraint(equalTo: topDocGiaCard.topAnchor, constant: 16),
            topDocGiaStack.leadingAnchor.constraint(equalTo: topDocGiaCard.leadingAnchor, constant: 16),
            topDocGiaStack.trailingAnchor.constraint(equalTo: topDocGiaCard.trailingAnchor, constant: -16),
            topDocGiaStack.bottomAnchor.constraint(equalTo: topDocGiaCard.bottomAnchor, constant: -16)
        ])
    }

    private func setupTopTacGiaCard() {
        AppTheme.applyCardStyle(to: topTacGiaCard)
        topTacGiaStack.axis = .vertical
        topTacGiaStack.spacing = 10
        topTacGiaStack.translatesAutoresizingMaskIntoConstraints = false
        topTacGiaCard.addSubview(topTacGiaStack)

        NSLayoutConstraint.activate([
            topTacGiaStack.topAnchor.constraint(equalTo: topTacGiaCard.topAnchor, constant: 16),
            topTacGiaStack.leadingAnchor.constraint(equalTo: topTacGiaCard.leadingAnchor, constant: 16),
            topTacGiaStack.trailingAnchor.constraint(equalTo: topTacGiaCard.trailingAnchor, constant: -16),
            topTacGiaStack.bottomAnchor.constraint(equalTo: topTacGiaCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Load Data
    @objc private func handleRefresh() {
        loadData()
        refreshControl.endRefreshing()
    }

    private func loadData() {
        let dm = DataManager.shared
        let dsPM = dm.dsPhieuMuon

        // 1. Cập nhật 4 thẻ KPI
        let tongLuotMuon = dsPM.count
        let doanhThuPhi = dsPM.reduce(0) { $0 + $1.phiMuonThucTe }
        let tienCocDangGiu = dsPM.filter { $0.ngayTra == nil }.reduce(0) { $0 + $1.tienCocThucTe }
        let tienPhatDaThu = dsPM.compactMap { $0.tienPhat }.reduce(0, +)

        kpiLuotMuon.setValue("\(tongLuotMuon)")
        kpiDoanhThu.setValue(AppTheme.formatVND(doanhThuPhi))
        kpiTienCoc.setValue(AppTheme.formatVND(tienCocDangGiu))
        kpiTienPhat.setValue(AppTheme.formatVND(tienPhatDaThu))

        // 2. Cập nhật Biểu đồ 7 ngày
        renderChart(dsPM: dsPM)

        // 3. Cập nhật Top Độc Giả
        renderTopDocGia(dsPM: dsPM, dsDG: dm.dsDocGia)

        // 4. Cập nhật Top Tác Giả
        renderTopTacGia(dsPM: dsPM, dsTG: dm.dsTacGia)
    }

    private func renderChart(dsPM: [PhieuMuon]) {
        chartStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let calendar = Calendar.current
        let today = Date()

        // Lấy 7 ngày qua
        var dailyCounts: [(day: String, count: Int)] = []
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let count = dsPM.filter { calendar.isDate($0.ngayMuon, inSameDayAs: date) }.count
            let df = DateFormatter()
            df.dateFormat = "dd/MM"
            dailyCounts.append((day: df.string(from: date), count: count))
        }

        let maxCount = max(dailyCounts.map { $0.count }.max() ?? 1, 1)

        for item in dailyCounts {
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 4

            let countLabel = UILabel()
            countLabel.text = "\(item.count)"
            countLabel.font = .systemFont(ofSize: 10, weight: .bold)
            countLabel.textColor = .secondaryLabel

            let barBg = UIView()
            barBg.backgroundColor = .systemGray6
            barBg.layer.cornerRadius = 4
            barBg.translatesAutoresizingMaskIntoConstraints = false
            barBg.heightAnchor.constraint(equalToConstant: 80).isActive = true
            barBg.widthAnchor.constraint(equalToConstant: 24).isActive = true

            let barFill = UIView()
            barFill.backgroundColor = .appPrimary
            barFill.layer.cornerRadius = 4
            barFill.translatesAutoresizingMaskIntoConstraints = false
            barBg.addSubview(barFill)

            let fillRatio = CGFloat(item.count) / CGFloat(maxCount)
            let fillHeight = max(80.0 * fillRatio, item.count > 0 ? 6.0 : 0.0)

            NSLayoutConstraint.activate([
                barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
                barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
                barFill.trailingAnchor.constraint(equalTo: barBg.trailingAnchor),
                barFill.heightAnchor.constraint(equalToConstant: fillHeight)
            ])

            let dayLabel = UILabel()
            dayLabel.text = item.day
            dayLabel.font = .systemFont(ofSize: 9, weight: .medium)
            dayLabel.textColor = .secondaryLabel

            col.addArrangedSubview(countLabel)
            col.addArrangedSubview(barBg)
            col.addArrangedSubview(dayLabel)
            chartStack.addArrangedSubview(col)
        }
    }

    private func renderTopDocGia(dsPM: [PhieuMuon], dsDG: [DocGia]) {
        topDocGiaStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = "🏆 Top 10 Độc Giả Tích Cực"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        topDocGiaStack.addArrangedSubview(titleLabel)

        // Đếm số lượt mượn theo độc giả
        var borrowCount: [UUID: Int] = [:]
        for pm in dsPM {
            if let id = pm.docGia?.maDocGia {
                borrowCount[id, default: 0] += 1
            }
        }

        let sorted = dsDG.filter { !($0.daAn) }
            .sorted { (borrowCount[$0.maDocGia] ?? 0) > (borrowCount[$1.maDocGia] ?? 0) }
            .prefix(10)

        if sorted.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Chưa có dữ liệu mượn trả"
            emptyLabel.font = .systemFont(ofSize: 13)
            emptyLabel.textColor = .secondaryLabel
            topDocGiaStack.addArrangedSubview(emptyLabel)
            return
        }

        for (idx, dg) in sorted.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .center

            let rankLabel = UILabel()
            rankLabel.text = "\(idx + 1)"
            rankLabel.font = .systemFont(ofSize: 13, weight: .bold)
            rankLabel.textColor = idx < 3 ? .appWarning : .secondaryLabel
            rankLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true

            let nameLabel = UILabel()
            nameLabel.text = dg.hoTen
            nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
            nameLabel.textColor = .label

            if dg.loaiThe == "VIP" {
                let vipBadge = AppTheme.createBadge(text: "VIP", textColor: .white, bgColor: .appGold)
                row.addArrangedSubview(rankLabel)
                row.addArrangedSubview(nameLabel)
                row.addArrangedSubview(vipBadge)
            } else {
                row.addArrangedSubview(rankLabel)
                row.addArrangedSubview(nameLabel)
            }

            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            row.addArrangedSubview(spacer)

            let countLabel = UILabel()
            let count = borrowCount[dg.maDocGia] ?? 0
            countLabel.text = "\(count) lượt"
            countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            countLabel.textColor = .appPrimary
            row.addArrangedSubview(countLabel)

            topDocGiaStack.addArrangedSubview(row)
        }
    }

    private func renderTopTacGia(dsPM: [PhieuMuon], dsTG: [TacGia]) {
        topTacGiaStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = "✍️ Top 10 Tác Giả Quan Tâm Nhất"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        topTacGiaStack.addArrangedSubview(titleLabel)

        var authorCount: [UUID: Int] = [:]
        for pm in dsPM {
            if let tgId = pm.banSao?.sach?.tacGia?.maTacGia {
                authorCount[tgId, default: 0] += 1
            }
        }

        let sorted = dsTG.sorted { (authorCount[$0.maTacGia] ?? 0) > (authorCount[$1.maTacGia] ?? 0) }.prefix(10)

        if sorted.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Chưa có dữ liệu tác giả"
            emptyLabel.font = .systemFont(ofSize: 13)
            emptyLabel.textColor = .secondaryLabel
            topTacGiaStack.addArrangedSubview(emptyLabel)
            return
        }

        for (idx, tg) in sorted.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .center

            let rankLabel = UILabel()
            rankLabel.text = "\(idx + 1)"
            rankLabel.font = .systemFont(ofSize: 13, weight: .bold)
            rankLabel.textColor = idx < 3 ? .appPrimary : .secondaryLabel
            rankLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true

            let nameLabel = UILabel()
            nameLabel.text = tg.tenTacGia
            nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
            nameLabel.textColor = .label

            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let countLabel = UILabel()
            let count = authorCount[tg.maTacGia] ?? 0
            countLabel.text = "\(count) cuốn"
            countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            countLabel.textColor = .secondaryLabel

            row.addArrangedSubview(rankLabel)
            row.addArrangedSubview(nameLabel)
            row.addArrangedSubview(spacer)
            row.addArrangedSubview(countLabel)

            topTacGiaStack.addArrangedSubview(row)
        }
    }
}

// MARK: - Reusable KPI Card View
private class KPICardView: UIView {
    private let valueLabel = UILabel()

    init(title: String, icon: String, color: UIColor) {
        super.init(frame: .zero)
        AppTheme.applyCardStyle(to: self)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let topRow = UIStackView(arrangedSubviews: [iconView, titleLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        valueLabel.text = "0"
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [topRow, valueLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ text: String) {
        valueLabel.text = text
    }
}
