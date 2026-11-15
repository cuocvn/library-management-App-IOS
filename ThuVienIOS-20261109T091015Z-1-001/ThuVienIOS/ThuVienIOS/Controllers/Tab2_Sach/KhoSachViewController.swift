//
//  KhoSachViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Tab 2 - Quản lý Kho Sách (Tìm kiếm, Lọc Thể Loại, Danh Sách Thẻ Sách)
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView, UISearchResultsUpdating
//

import UIKit

class KhoSachViewController: UIViewController {

    // MARK: - UI Components
    private let searchController = UISearchController(searchResultsController: nil)
    private let filterScrollView = UIScrollView()
    private let filterStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Data
    private var dsSachHienThi: [Sach] = []
    private var selectedTheLoai: TheLoai? = nil
    private var currentSearchText: String = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kho Sách"
        view.backgroundColor = .appBackground
        
        setupNavigation()
        setupSearch()
        setupFilterPills()
        setupTableView()
        reloadBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFilterPills()
        reloadBooks()
    }

    // MARK: - Setup UI
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Kho Sách"

        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(themSachTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm theo tên sách, tác giả..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupFilterPills() {
        filterScrollView.showsHorizontalScrollIndicator = false
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterScrollView)

        filterStackView.axis = .horizontal
        filterStackView.spacing = 8
        filterStackView.alignment = .center
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        filterScrollView.addSubview(filterStackView)

        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 44),

            filterStackView.topAnchor.constraint(equalTo: filterScrollView.topAnchor, constant: 4),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.trailingAnchor, constant: -16),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: -4),
            filterStackView.heightAnchor.constraint(equalTo: filterScrollView.heightAnchor, constant: -8)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SachCell.self, forCellReuseIdentifier: "SachCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data Logic
    private func reloadFilterPills() {
        filterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Nút "Tất cả"
        let allBtn = createFilterButton(title: "Tất cả", isSelected: selectedTheLoai == nil)
        allBtn.tag = -1
        allBtn.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        filterStackView.addArrangedSubview(allBtn)

        let dsTL = DataManager.shared.dsTheLoai
        for (idx, tl) in dsTL.enumerated() {
            let isSel = selectedTheLoai?.maTheLoai == tl.maTheLoai
            let btn = createFilterButton(title: tl.tenTheLoai, isSelected: isSel)
            btn.tag = idx
            btn.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            filterStackView.addArrangedSubview(btn)
        }
    }

    private func createFilterButton(title: String, isSelected: Bool) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("  \(title)  ", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: isSelected ? .bold : .medium)
        btn.setTitleColor(isSelected ? .white : .label, for: .normal)
        btn.backgroundColor = isSelected ? .appPrimary : .secondarySystemGroupedBackground
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = isSelected ? 0 : 0.5
        btn.layer.borderColor = UIColor.separator.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return btn
    }

    @objc private func filterTapped(_ sender: UIButton) {
        if sender.tag == -1 {
            selectedTheLoai = nil
        } else {
            let dsTL = DataManager.shared.dsTheLoai
            if sender.tag < dsTL.count {
                selectedTheLoai = dsTL[sender.tag]
            }
        }
        reloadFilterPills()
        reloadBooks()
    }

    private func reloadBooks() {
        let allBooks = DataManager.shared.dsSach.filter { !$0.daAn }
        dsSachHienThi = allBooks.filter { book in
            let matchCat = selectedTheLoai == nil || book.theLoai?.maTheLoai == selectedTheLoai?.maTheLoai
            let matchText = currentSearchText.isEmpty ||
                book.tenSach.localizedCaseInsensitiveContains(currentSearchText) ||
                (book.tacGia?.tenTacGia.localizedCaseInsensitiveContains(currentSearchText) ?? false)
            return matchCat && matchText
        }
        tableView.reloadData()
    }

    @objc private func themSachTapped() {
        let vc = ThemSuaSachViewController(mode: .them)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - Search Updating
extension KhoSachViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        currentSearchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        reloadBooks()
    }
}

// MARK: - TableView DataSource & Delegate
extension KhoSachViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsSachHienThi.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SachCell", for: indexPath) as? SachCell else {
            return UITableViewCell()
        }
        let sach = dsSachHienThi[indexPath.row]
        cell.configure(sach: sach)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sach = dsSachHienThi[indexPath.row]
        let vc = ChiTietSachViewController(sach: sach)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sach = dsSachHienThi[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            let alert = UIAlertController(title: "Xác nhận xóa", message: "Bạn có chắc muốn xóa đầu sách '\(sach.tenSach)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                DataManager.shared.xoaSach(sach)
                self?.reloadBooks()
                completion(true)
            })
            self?.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Custom Sach Cell
private class SachCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let stockBadge = UILabel()
    private let priceTag = UILabel()
    private let valueBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = .appCardBg

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .secondaryLabel

        let topRow = UIStackView(arrangedSubviews: [titleLabel])
        topRow.axis = .horizontal

        let metaRow = UIStackView(arrangedSubviews: [authorLabel])
        metaRow.axis = .horizontal

        let badgeRow = UIStackView(arrangedSubviews: [stockBadge, valueBadge, priceTag])
        badgeRow.axis = .horizontal
        badgeRow.spacing = 6
        badgeRow.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [topRow, metaRow, badgeRow])
        mainStack.axis = .vertical
        mainStack.spacing = 6
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

    func configure(sach: Sach) {
        titleLabel.text = sach.tenSach
        let author = sach.tacGia?.tenTacGia ?? "Chưa rõ TG"
        let cat = sach.theLoai?.tenTheLoai ?? "Thể loại khác"
        authorLabel.text = "\(author) • \(cat) (\(sach.namXuatBan))"

        let totalCopies = sach.dsBanSao.count
        let availableCopies = sach.dsBanSao.filter { $0.tinhTrang == "SanSang" }.count

        stockBadge.text = " Còn \(availableCopies)/\(totalCopies) cuốn "
        stockBadge.font = .systemFont(ofSize: 11, weight: .bold)
        stockBadge.layer.cornerRadius = 6
        stockBadge.layer.masksToBounds = true
        if availableCopies > 0 {
            stockBadge.textColor = .appSuccess
            stockBadge.backgroundColor = UIColor.appSuccess.withAlphaComponent(0.12)
        } else {
            stockBadge.textColor = .appDanger
            stockBadge.backgroundColor = UIColor.appDanger.withAlphaComponent(0.12)
        }

        valueBadge.text = " \(sach.phanLoaiGiaTri) "
        valueBadge.font = .systemFont(ofSize: 11, weight: .medium)
        valueBadge.textColor = .appPrimary
        valueBadge.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
        valueBadge.layer.cornerRadius = 6
        valueBadge.layer.masksToBounds = true

        priceTag.text = " Cọc: \(AppTheme.formatVND(sach.tienCoc)) "
        priceTag.font = .systemFont(ofSize: 11)
        priceTag.textColor = .secondaryLabel
        priceTag.backgroundColor = .systemGray6
        priceTag.layer.cornerRadius = 6
        priceTag.layer.masksToBounds = true
    }
}
