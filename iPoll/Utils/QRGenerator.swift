//
//  QRGenerator.swift
//  iPoll
//
//  Created by Evans Owamoyo on 21.03.2022.
//

import Foundation
import CoreImage
import UIKit

struct QRGenerator {
    private static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    static func generatePollQR(poll id: String) -> UIImage? {
        return generateQRCode(from: "ipoll://poll?id=\(id)")
    }
}
