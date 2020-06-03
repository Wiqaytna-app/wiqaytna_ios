//
//  UIRefreshControl.swift
//  Wiqaytna
//
//  Created by Abdel Ali on 3/6/20.
//  Copyright © 2020 OpenTrace. All rights reserved.
//

import UIKit

extension UIRefreshControl {

    static func defaultRefreshControl(_ target: Any?, selectorAction: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "pull_to_refresh".localized())
        refreshControl.addTarget(target, action: selectorAction, for: .valueChanged)

        return refreshControl
    }
}
