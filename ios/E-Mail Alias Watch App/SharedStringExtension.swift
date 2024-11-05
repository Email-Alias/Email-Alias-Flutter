//
//  StringExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
import EFQRCode

extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func generateQRCode() -> UIImage? {
        if let cgImage = EFQRCode.generate(for: self) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
}
