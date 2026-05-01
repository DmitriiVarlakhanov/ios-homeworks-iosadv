//
//  AuthenticationViewController.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 3/18/26.
//

import UIKit

class AuthenticationViewController: UIViewController {

    // MARK: - Properties

    private lazy var faceIDButton: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(systemName: "faceid")
        imageView.isUserInteractionEnabled = true

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(faceIDButtonTapped)
        )

        imageView.addGestureRecognizer(gestureRecognizer)

        return imageView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRootView()
        self.addSubviews()
        self.setupConstraints()

        LocalAuthenticationService.shared.authorizeIfPossible { result in
            print("Auth status - \(result)")
        }
    }

    // MARK: - Actions

    @objc private func faceIDButtonTapped() {
        LocalAuthenticationService.shared.authorizeIfPossible { result in
            print("Auth status - \(result)")
        }
    }

    // MARK: - Private

    private func setupRootView() {
        self.view.backgroundColor = .white
    }

    private func addSubviews() {
        self.view.addSubview(faceIDButton)
    }

    private func setupConstraints() {
        let safeAreaGuide = self.view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            self.faceIDButton.centerXAnchor.constraint(equalTo: safeAreaGuide.centerXAnchor),
            self.faceIDButton.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor, constant: 300),
            self.faceIDButton.widthAnchor.constraint(equalToConstant: 50),
            self.faceIDButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
