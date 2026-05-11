//
//  DragAndDropTableViewCell.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 5/1/26.
//

import UIKit

class DragAndDropTableViewCell: UITableViewCell {

    //MARK: - Properties

    private lazy var nameLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label

        return label
    }()

    private lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill

        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true

        return imageView
    }()

    //MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubviews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Private

    private func addSubviews() {
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(mainImageView)
    }

    private func setupConstraints() {
        let safeAreaLayoutGuide = self.contentView.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            mainImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            mainImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            mainImageView.heightAnchor.constraint(equalToConstant: 50),
            mainImageView.widthAnchor.constraint(equalToConstant: 50),

            nameLabel.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 40),
        ])
    }

    //MARK: - Public

    func update(indexPathRow: Int) {
        self.nameLabel.text = DragAndDropModel.shared.names[indexPathRow]
        self.mainImageView.image = DragAndDropModel.shared.images[indexPathRow]
    }
}
