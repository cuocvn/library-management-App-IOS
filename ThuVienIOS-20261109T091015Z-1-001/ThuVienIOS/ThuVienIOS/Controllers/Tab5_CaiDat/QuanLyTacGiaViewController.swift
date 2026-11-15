//
//  QuanLyTacGiaViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.3 - Quản lý Danh mục Tác Giả
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView
//

import UIKit

class QuanLyTacGiaViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dsTacGia: [TacGia] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quản Lý Tác Giả"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupTableView()
        reloadAuthors()
    }

    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(themTacGiaTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AuthorCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func reloadAuthors() {
        dsTacGia = DataManager.shared.dsTacGia
        tableView.reloadData()
    }

    @objc private func themTacGiaTapped() {
        let alert = UIAlertController(title: "Thêm Tác Giả", message: "Nhập tên tác giả mới:", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "VD: Nam Cao, Tô Hoài..." }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Thêm", style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                _ = DataManager.shared.layHoacTaoTacGia(text)
                self?.reloadAuthors()
            }
        })
        present(alert, animated: true)
    }
}

extension QuanLyTacGiaViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsTacGia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "AuthorCell")
        let tg = dsTacGia[indexPath.row]
        cell.textLabel?.text = tg.tenTacGia
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.detailTextLabel?.text = "\(tg.dsSach.count) đầu sách"
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tg = dsTacGia[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            let alert = UIAlertController(title: "Xóa tác giả", message: "Bạn có chắc muốn xóa tác giả '\(tg.tenTacGia)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                DataManager.shared.xoaTacGia(tg)
                self?.reloadAuthors()
                completion(true)
            })
            self?.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
