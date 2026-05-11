//
//  DragAndDropModel.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 5/1/26.
//

import Foundation
import UIKit

struct DragAndDropModel {

    // MARK: - Type properties

    static var shared = DragAndDropModel()

    // MARK: - Properties

    var names: [String] = []
    var images: [UIImage] = []

    // MARK: - Initialization

    private init() {
        self.createModel()
    }

    // MARK: - Private

    private mutating func createModel() {
        for i in 0...3 {
            names.append("Name \(i)")
            images.append(UIImage(named: "Image\(i)")!)
        }
    }
}
