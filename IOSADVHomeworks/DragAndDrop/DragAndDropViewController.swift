//
//  DragAndDropViewController.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 5/1/26.
//

import UIKit
import UniformTypeIdentifiers

class DragAndDropViewController: UIViewController {

    // MARK: - Properties

    private enum CellReuseID: String {
        case dragAndDropTableViewCell = "CellReuseID_DragAndDropTableViewCell"
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(
            DragAndDropTableViewCell.self,
            forCellReuseIdentifier: CellReuseID.dragAndDropTableViewCell.rawValue
        )

        tableView.dataSource = self
        tableView.delegate = self

        tableView.dragInteractionEnabled = true

        tableView.dragDelegate = self
        tableView.dropDelegate = self

        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRootView()
        self.addSubviews()
        self.setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Private

    private func setupRootView() {
        self.view.backgroundColor = .systemBackground
    }

    private func addSubviews() {
        self.view.addSubview(tableView)
    }

    private func setupConstraints() {
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
}

// MARK: - UITableViewDataSource

extension DragAndDropViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DragAndDropModel.shared.names.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellReuseID.dragAndDropTableViewCell.rawValue,
            for: indexPath
        ) as! DragAndDropTableViewCell

        cell.update(indexPathRow: indexPath.row)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension DragAndDropViewController: UITableViewDelegate {

}

// MARK: - UITableViewDragDelegate

extension DragAndDropViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let nameText = DragAndDropModel.shared.names[indexPath.row]
        let nameTextData = nameText.data(using: .utf8)
        let itemProvider = NSItemProvider()

        itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.utf8PlainText.identifier, visibility: .all) { completion in
            completion(nameTextData, nil)

            return nil
        }

        let dragItem = UIDragItem(itemProvider: itemProvider)

        let image = DragAndDropModel.shared.images[indexPath.row]
        let imageData = image.pngData()
        let itemProvider2 = NSItemProvider()

        itemProvider2.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
            completion(imageData, nil)

            return nil
        }

        let dragItem2 = UIDragItem(itemProvider: itemProvider2)

        return [dragItem, dragItem2]
    }
}

// MARK: - UITableViewDropDelegate

extension DragAndDropViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
        let firstBoolean = session.canLoadObjects(ofClass: UIImage.self)
        let secondBoolean = session.canLoadObjects(ofClass: NSString.self)
        return firstBoolean || secondBoolean
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        var counter = 0

        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            let stringItems = items as! [String]
            for textItem in stringItems {
                DragAndDropModel.shared.names.insert(textItem, at: DragAndDropModel.shared.names.count)
                DragAndDropModel.shared.images.insert(UIImage(), at: DragAndDropModel.shared.images.count)
            }

            counter += 1

            tableView.reloadData()
        }

        coordinator.session.loadObjects(ofClass: UIImage.self) { items in
            let imageItems = items as! [UIImage]

            for imageItem in imageItems {
                DragAndDropModel.shared.images.insert(imageItem, at: DragAndDropModel.shared.images.count)
            }

            if counter == 1 {
                if DragAndDropModel.shared.names.count == DragAndDropModel.shared.images.count {
                    return
                } else {
                    DragAndDropModel.shared.images.remove(at: DragAndDropModel.shared.images.count - 2)
                }
            } else {
                DragAndDropModel.shared.names.insert("New Name", at: DragAndDropModel.shared.names.count)
            }

            tableView.reloadData()
        }
    }
}
