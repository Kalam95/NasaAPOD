//
//  ShoppingListViewController.swift
//
//  Created by mehboob Alam
//

import UIKit

public enum ListType {
    case history, favourites
}
class AstronomyListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbarView: SearbarView!
    
    private let viewModel: AstronomyListViewModel
    private let router: APODHomeRouter

    init(viewModel: AstronomyListViewModel, router: APODHomeRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        NotificationCenter.default.removeObserver(self)
        setupUIView()
        viewModel.getData()
        if navigationController?.viewControllers.count ?? 0 <= 1 {
            addRightButtion(title: "Cancel")
        }
    }

    override func rightBarButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.viewType == .favourites {
            viewModel.getData()
        }
    }

    deinit {
        searchbarView.dateField.clearContext()
    }

    private func bindView() {
        viewModel.signal.subscribe(onNext: {[weak self] _ in
            self?.updateView()
        })
        searchbarView.dateField.value.subscribe(onNext: {[weak self] date in
            self?.viewModel.filter(forDate: date)
            self?.updateView()
        })
    }

    private func setupUIView() {
        title = viewModel.viewType == .history ? "Recent Searches" : "Favourites"
        searchbarView.isClearButtonVisisble = true
        tableView.registerCell(type: AstronomyDataCell.self)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        barTintColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func updateView() {
        tableView.reloadData()
        tableView.backgroundView =  viewModel.numberOfRows > 0  ? nil : getPlaceholderView()
    }

    private func getPlaceholderView() -> UIView {
        let label = UILabel()
        label.textColor = .appThemeColor
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Currently you do not have any \(title ?? "saved data")"
        return label
    }
}

extension AstronomyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AstronomyDataCell = tableView.dequeueTypedCell(for: indexPath)
        cell.populateCell(with: viewModel.getItem(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.delete(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.getItem(at: indexPath.row) else { return }
        router.showDetailView(data: data, source: self)
    }
}
