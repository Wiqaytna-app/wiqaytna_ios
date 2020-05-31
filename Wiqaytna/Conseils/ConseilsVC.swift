//
//  ConseilsVC.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 5/7/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import UIKit
import Firebase

class ConseilsVC: UIViewController {

    @IBOutlet weak var HelpTitle: UILabel!
    @IBOutlet weak var TableViewConseil: UITableView!
    @IBOutlet weak var BarBottomConseils: UITabBarItem!
    @IBOutlet weak var HelpSubTitle: UILabel!

    var dataConseils = [[String: String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":9, "screen":"ecran conseils"] as [String : Any]
        Analytics.logEvent("advices_screen", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }

    @objc func updateText() {
        HelpTitle.text = "HelpTitle".localized()
        HelpSubTitle.text = "HelpSubTitle".localized()
        BarBottomConseils.title = "BarBottomConseils".localized()

        if LanguageManager.currentLanguage() == "ar" {
            dataConseils = ConseilsConstants.conseilsAR
        } else {
            dataConseils = ConseilsConstants.conseilsFR
        }

        self.TableViewConseil.reloadData()
        self.TableViewConseil.estimatedRowHeight = 230
   }
}

extension ConseilsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataConseils.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)

        guard indexPath.row > 0, indexPath.row < dataConseils.count else {
            return UITableViewCell()
        }

        let conseil = dataConseils[indexPath.row]
        guard
            let text = conseil["text"],
            let image = conseil["image"]
        else {
            return UITableViewCell()
        }
    
        let labelConseil = cell.viewWithTag(100) as! UILabel
        labelConseil.text = text

        let imageConseil = cell.viewWithTag(50) as! UIImageView
        imageConseil.image =  UIImage(named: image)

        let contentStack = cell.viewWithTag(150)
        contentStack!.layer.cornerRadius = 7.0
        cell.backgroundColor = UIColor.clear
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }
}
