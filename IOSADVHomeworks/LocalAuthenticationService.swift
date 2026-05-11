//
//  LocalAuthenticationService.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 3/17/26.
//

import Foundation
import UIKit
import LocalAuthentication

class LocalAuthenticationService {

    // MARK: - Type properties

    static let shared = LocalAuthenticationService()

    // MARK: - Properties

    private let laContext = LAContext()

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Public

    func authorizeIfPossible(_ authorizationFinished: @escaping (Bool) -> Void) {
        if self.laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            self.laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Please enter iPhone's passcode") { success, error in
                if let error = error as NSError? {
                    print(error.localizedDescription)

                    return
                }

                DispatchQueue.main.async {
                    let tabBarController = UITabBarController()

                    let mapNavigationController = UINavigationController(rootViewController: MapViewController())

                    let dragAndDropViewController = UINavigationController(rootViewController: DragAndDropViewController())

                    let tabBarItem = UITabBarItem(title: "Drag and Drop", image: UIImage(systemName: "hand.draw"), tag: 0)

                    dragAndDropViewController.tabBarItem = tabBarItem

                    tabBarController.viewControllers = [mapNavigationController, dragAndDropViewController]

                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                        return
                    }

                    window.rootViewController = tabBarController
                }

                authorizationFinished(true)
            }
        } else {
            authorizationFinished(false)

            print("Failure")
        }
    }
}
