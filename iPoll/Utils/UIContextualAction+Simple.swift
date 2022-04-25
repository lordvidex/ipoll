//
//  UIContextualAction+Simple.swift
//  iPoll
//
//  Created by Evans Owamoyo on 25.04.2022.
//

import UIKit

extension UIContextualAction {
    static func simple(style: UIContextualAction.Style = .normal,
                       title: String,
                       backgroundColor: UIColor? = Constants.Colors.lightBlue,
                       image: UIImage? = nil,
                       action: @escaping () -> Void
    ) -> UIContextualAction {
       let context =  UIContextualAction(style: .normal, title: title) { _, _, completion in
            action()
            completion(true)
        }
        if let bgColor = backgroundColor {
            context.backgroundColor = bgColor
        }
        context.image = image

        return context
    }
}
