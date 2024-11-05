//
//  ImageExtension.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

extension Image {
    init(native nativeImage: UIImage) {
        self.init(uiImage: nativeImage)
    }
}
