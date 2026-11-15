//
//  DocGiaViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Tab 4 - Quản lý Độc Giả, Huy Hiệu VIP & Số Dư Ví Nội Bộ
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView, UISearchResultsUpdating, UISegmentedControl
//

import UIKit

class DocGiaViewController: UIViewController {

    // UI Components
    private let searchController = UISearchController(searchResultsController: nil)
    private let segmentedControl = UISegmentedControl(items: ["Tất cả", "Thường", "👑 VIP"])
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Data
    private var dsHienThi: [DocGia] = []
    private var currentSearchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Độc Giả"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupSearch()
        setupSegmentedControl()
        setupTableView()
        reloadReaders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadReaders()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Độc Giả"

        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(themDocGiaTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm theo tên, SĐT, lớp..."
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
        tableView.register(DocGiaCell.self, forCellReuseIdentifier: "DocGiaCell")
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
        reloadReaders()
    }

    private func reloadReaders() {
        let all = DataManager.shared.dsDocGia.filter { !$0.daAn }

        dsHienThi = all.filter { dg in
            let matchType: Bool
            switch segmentedControl.selectedSegmentIndex {
            case 1: matchType = dg.loaiThe == "Thuong"
            case 2: matchType = dg.loaiThe == "VIP"
            default: matchType = true
            }

            let matchText: Bool
            if currentSearchText.isEmpty {
                matchText = true
            } else {
                let name = dg.hoTen.localizedCaseInsensitiveContains(currentSearchText)
                let phone = dg.soDienThoai.localizedCaseInsensitiveContains(currentSearchText)
                let lop = dg.lopKhoa.localizedCaseInsensitiveContains(currentSearchText)
                matchText = name || phone || lop
            }

            return matchType && matchText
        }
        tableView.reloadData()
    }

    @objc private func themDocGiaTapped() {
        let vc = ThemSuaDocGiaViewController(mode: .them)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - Search Updating
extension DocGiaViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        currentSearchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        reloadReaders()
    }
}

// MARK: - TableView DataSource & Delegate
extension DocGiaViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsHienThi.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocGiaCell", for: indexPath) as? DocGiaCell else {
            return UITableViewCell()
        }
        let dg = dsHienThi[indexPath.row]
        cell.configure(dg: dg)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dg = dsHienThi[indexPath.row]
        let vc = ChiTietDocGiaViewController(docGia: dg)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dg = dsHienThi[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            let alert = UIAlertController(title: "Xác nhận xóa", message: "Bạn có chắc muốn xóa độc giả '\(dg.hoTen)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                DataManager.shared.xoaDocGia(dg)
                self?.reloadReaders()
                completion(true)
            })
            self?.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Custom DocGia Cell
private class DocGiaCell: UITableViewCell {
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let vipBadge = UILabel()
    private let infoLabel = UILabel()
    private let walletLabel = UILabel()
    private let borrowingBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = .appCardBg

        // Avatar tròn chữ cái đầu
        avatarLabel.font = .systemFont(ofSize: 16, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.backgroundColor = .appPrimary
        avatarLabel.textAlignment = .center
        avatarLabel.layer.cornerRadius = 20
        avatarLabel.layer.masksToBounds = true
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .label

        vipBadge.text = " VIP "
        vipBadge.font = .systemFont(ofSize: 11, weight: .bold)
        vipBadge.textColor = .white
        vipBadge.backgroundColor = .appGold
        vipBadge.layer.cornerRadius = 4
        vipBadge.layer.masksToBounds = true

        let nameRow = UIStackView(arrangedSubviews: [nameLabel, vipBadge])
        nameRow.axis = .horizontal
        nameRow.spacing = 8
        nameRow.alignment = .center

        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel

        walletLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        walletLabel.textColor = .appSuccess

        borrowingBadge.font = .systemFont(ofSize: 11, weight: .medium)
        borrowingBadge.textColor = .appPrimary
        borrowingBadge.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
        borrowingBadge.layer.cornerRadius = 4
        borrowingBadge.layer.masksToBounds = true

        let metaRow = UIStackView(arrangedSubviews: [walletLabel, borrowingBadge])
        metaRow.axis = .horizontal
        metaRow.spacing = 8
        metaRow.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [nameRow, infoLabel, metaRow])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [avatarLabel, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
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

    func configure(dg: DocGia) {
        nameLabel.text = dg.hoTen
        let initial = String(dg.hoTen.prefix(1)).uppercased()
        avatarLabel.text = initial

        let isVIP = dg.loaiThe == "VIP"
        vipBadge.isHidden = !isVIP
        avatarLabel.backgroundColor = isVIP ? .appGold : .appPrimary

        infoLabel.text = "\(dg.lopKhoa.isEmpty ? "Độc giả" : dg.lopKhoa) • \(dg.soDienThoai)"
        walletLabel.text = "Ví: \(AppTheme.formatVND(dg.soDuTaiKhoan))"

        let borrowingCount = dg.dsPhieuMuon.filter { $0.ngayTra == nil }.count
        if borrowingCount > 0 {
            borrowingBadge.text = " Đang mượn \(borrowingCount) cuốn "
            borrowingBadge.isHidden = false
        } else {
            borrowingBadge.isHidden = true
        }
    }
}
