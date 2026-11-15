//
//  QuanLyNXBViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.2 - Quản lý Nhà Xuất Bản
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView
//

import UIKit

class QuanLyNXBViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dsNXB: [NhaXuatBan] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nhà Xuất Bản"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupTableView()
        reloadPublishers()
    }

    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(themNXBTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NxbCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func reloadPublishers() {
        dsNXB = DataManager.shared.dsNXB
        tableView.reloadData()
    }

    @objc private func themNXBTapped() {
        let alert = UIAlertController(title: "Thêm Nhà Xuất Bản", message: "Nhập tên nhà xuất bản mới:", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "VD: NXB Trẻ, NXB Tổng Hợp..." }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Thêm", style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                _ = DataManager.shared.layHoacTaoNXB(text)
                self?.reloadPublishers()
            }
        })
        present(alert, animated: true)
    }
}

extension QuanLyNXBViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsNXB.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "NxbCell")
        let nxb = dsNXB[indexPath.row]
        cell.textLabel?.text = nxb.tenNXB
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.detailTextLabel?.text = "\(nxb.dsSach.count) đầu sách"
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let nxb = dsNXB[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            let alert = UIAlertController(title: "Xóa NXB", message: "Bạn có chắc muốn xóa NXB '\(nxb.tenNXB)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                DataManager.shared.xoaNXB(nxb)
                self?.reloadPublishers()
                completion(true)
            })
            self?.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
