//
//  MuonTraViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Tab 3 - Nghiệp vụ Mượn & Trả Sách (Fintech Core, Lọc Trạng Thái, Đối Soát)
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView, UISegmentedControl, UISearchResultsUpdating
//

import UIKit

class MuonTraViewController: UIViewController {

    // UI Components
    private let segmentedControl = UISegmentedControl(items: ["Tất cả", "Đang mượn", "Quá hạn", "Đã trả"])
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Data
    private var dsHienThi: [PhieuMuon] = []
    private var currentSearchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mượn & Trả"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupSearch()
        setupSegmentedControl()
        setupTableView()
        reloadTransactions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTransactions()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Mượn & Trả"

        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(taoPhieuTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm theo tên sách, độc giả, mã sách..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhieuMuonCell.self, forCellReuseIdentifier: "PhieuMuonCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func filterChanged() {
        reloadTransactions()
    }

    private func reloadTransactions() {
        let all = DataManager.shared.dsPhieuMuon.sorted { $0.ngayMuon > $1.ngayMuon }
        let today = Date()

        dsHienThi = all.filter { pm in
            // Lọc theo Segment
            let matchStatus: Bool
            switch segmentedControl.selectedSegmentIndex {
            case 1: // Đang mượn
                matchStatus = pm.ngayTra == nil
            case 2: // Quá hạn
                matchStatus = pm.ngayTra == nil && pm.hanTra < today
            case 3: // Đã trả
                matchStatus = pm.ngayTra != nil
            default: // Tất cả
                matchStatus = true
            }

            // Lọc theo từ khóa
            let matchText: Bool
            if currentSearchText.isEmpty {
                matchText = true
            } else {
                let sName = pm.banSao?.sach?.tenSach ?? ""
                let bCode = pm.banSao?.maDinhDanh ?? ""
                let rName = pm.docGia?.hoTen ?? ""
                matchText = sName.localizedCaseInsensitiveContains(currentSearchText) ||
                    bCode.localizedCaseInsensitiveContains(currentSearchText) ||
                    rName.localizedCaseInsensitiveContains(currentSearchText)
            }

            return matchStatus && matchText
        }
        tableView.reloadData()
    }

    @objc private func taoPhieuTapped() {
        let vc = TaoPhieuMuonViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - Search Updating
extension MuonTraViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        currentSearchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        reloadTransactions()
    }
}

// MARK: - TableView DataSource & Delegate
extension MuonTraViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsHienThi.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhieuMuonCell", for: indexPath) as? PhieuMuonCell else {
            return UITableViewCell()
        }
        let pm = dsHienThi[indexPath.row]
        cell.configure(pm: pm)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pm = dsHienThi[indexPath.row]
        let vc = TraSachViewController(phieuMuon: pm)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pm = dsHienThi[indexPath.row]
        if pm.ngayTra == nil {
            let returnAction = UIContextualAction(style: .normal, title: "Trả sách") { [weak self] _, _, completion in
                let vc = TraSachViewController(phieuMuon: pm)
                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true)
                completion(true)
            }
            returnAction.backgroundColor = .appSuccess
            return UISwipeActionsConfiguration(actions: [returnAction])
        }
        return nil
    }
}

// MARK: - Custom PhieuMuon Cell
private class PhieuMuonCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let codeBadge = UILabel()
    private let readerLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusBadge = UILabel()
    private let feeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = .appCardBg

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .label

        codeBadge.font = .systemFont(ofSize: 11, weight: .bold)
        codeBadge.textColor = .appPrimary
        codeBadge.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.12)
        codeBadge.layer.cornerRadius = 4
        codeBadge.layer.masksToBounds = true

        let topRow = UIStackView(arrangedSubviews: [codeBadge, titleLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        readerLabel.font = .systemFont(ofSize: 13, weight: .medium)
        readerLabel.textColor = .secondaryLabel

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel

        let statusRow = UIStackView(arrangedSubviews: [statusBadge, feeLabel])
        statusRow.axis = .horizontal
        statusRow.spacing = 8
        statusRow.alignment = .center

        statusBadge.font = .systemFont(ofSize: 11, weight: .bold)
        statusBadge.layer.cornerRadius = 6
        statusBadge.layer.masksToBounds = true

        feeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        feeLabel.textColor = .secondaryLabel

        let mainStack = UIStackView(arrangedSubviews: [topRow, readerLabel, dateLabel, statusRow])
        mainStack.axis = .vertical
        mainStack.spacing = 5
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(pm: PhieuMuon) {
        titleLabel.text = pm.banSao?.sach?.tenSach ?? "Chưa rõ sách"
        codeBadge.text = " \(pm.banSao?.maDinhDanh ?? "") "

        let dgName = pm.docGia?.hoTen ?? "Khách"
        let isVIP = pm.docGia?.loaiThe == "VIP"
        readerLabel.text = "Độc giả: \(dgName)\(isVIP ? " 👑 VIP" : "")"

        let ngayMuonStr = AppTheme.formatDate(pm.ngayMuon)
        let hanTraStr = AppTheme.formatDate(pm.hanTra)

        if let ngayTra = pm.ngayTra {
            dateLabel.text = "Mượn: \(ngayMuonStr) ➔ Trả: \(AppTheme.formatDate(ngayTra))"
            statusBadge.text = " Đã trả "
            statusBadge.textColor = .secondaryLabel
            statusBadge.backgroundColor = .systemGray5

            if let phat = pm.tienPhat, phat > 0 {
                feeLabel.text = "Phạt: \(AppTheme.formatVND(phat))"
                feeLabel.textColor = .appDanger
            } else {
                feeLabel.text = "Đúng hạn"
                feeLabel.textColor = .appSuccess
            }
        } else {
            let isOverdue = pm.hanTra < Date()
            dateLabel.text = "Mượn: \(ngayMuonStr) ➔ Hạn: \(hanTraStr)"

            if isOverdue {
                let days = max(1, Calendar.current.dateComponents([.day], from: pm.hanTra, to: Date()).day ?? 1)
                statusBadge.text = " Quá hạn \(days) ngày "
                statusBadge.textColor = .white
                statusBadge.backgroundColor = .appDanger
                feeLabel.text = "Cọc: \(AppTheme.formatVND(pm.tienCocThucTe))"
                feeLabel.textColor = .appDanger
            } else {
                statusBadge.text = " Đang mượn "
                statusBadge.textColor = .appPrimary
                statusBadge.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.12)
                feeLabel.text = "Cọc: \(AppTheme.formatVND(pm.tienCocThucTe))"
                feeLabel.textColor = .secondaryLabel
            }
        }
    }
}
