//
//  StatisticsPageViewController.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 4/30/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import UIKit
import FirebaseFunctions
import Firebase

class StatisticsPageViewController: UIViewController {
    
    @IBOutlet weak var StatisticsTitle: UILabel!
    @IBOutlet weak var StatisticsSubTitle: UILabel!
    @IBOutlet weak var StatisticsNombreTotal: UILabel!
    @IBOutlet weak var StatisticsNombreCasConfirmes: UILabel!
    
    @IBOutlet weak var LabelCasConfirmesOne: UILabel!
    @IBOutlet weak var LabelGuerisOne: UILabel!
    @IBOutlet weak var LabelDecesOne: UILabel!
    
    @IBOutlet weak var LabelCasConfirmesOneNb: UILabel!
    @IBOutlet weak var LabelGuerisOneNb: UILabel!
    @IBOutlet weak var LabelDecesOneNb: UILabel!
    
    @IBOutlet weak var LabelCasConfirmesTwo: UILabel!
    @IBOutlet weak var LabelGuerisTwo: UILabel!
    @IBOutlet weak var LabelDecesTwo: UILabel!
    
    @IBOutlet weak var LabelCasConfirmesTwoNb: UILabel!
    @IBOutlet weak var LabelGuerisTwoNb: UILabel!
    @IBOutlet weak var LabelDecesTwoNb: UILabel!
    
    @IBOutlet weak var BarBottomStatistics: UITabBarItem!
    
    @IBOutlet weak var TableViewRegion: UITableView!
    @IBOutlet weak var TableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let statsCellHeight = 65
    var dataRegions:[Dictionary<String,Any>] = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":8, "screen":"ecran statistiques"] as [String : Any]
        Analytics.logEvent("statistics_screen", parameters: _parameters)
        setScrollView()
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDataStatistics()
    }
    
    @objc func updateText() {
        StatisticsTitle.text = "StatisticsTitle".localized()
        StatisticsSubTitle.text = "StatisticsSubTitle".localized()
        StatisticsNombreTotal.text = "StatisticsNombreTotal".localized()
        StatisticsNombreCasConfirmes.text = "StatisticsNombreCasConfirmes".localized()
        
        LabelCasConfirmesOne.text = "StatusCasConfirmes".localized()
        LabelGuerisOne.text = "StatusGueris".localized()
        LabelDecesOne.text = "StatusDeces".localized()
        
        LabelCasConfirmesTwo.text = "StatusCasConfirmes".localized()
        LabelGuerisTwo.text = "StatusGueris".localized()
        LabelDecesTwo.text = "StatusDeces".localized()
        
        BarBottomStatistics.title = "BarBottomStatistics".localized()
        
    }
    
    private func setScrollView() {
        scrollView.refreshControl = UIRefreshControl.defaultRefreshControl(self, selectorAction: #selector(getDataStatistics))

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    @objc func getDataStatistics() {

        if AppDelegate.statsDict != nil {
            self.displayStats(statsDict: AppDelegate.statsDict!)
            return
        }
        StatisticsServices.statistics { [weak self] (statsDict) in
            guard let self = self else { return }
            self.displayStats(statsDict: statsDict)
            UserDefaults.standard.set(Date(), forKey: AppDelegate.lastUpdateStatsKey)
        }
    }
    
    private func displayStats(statsDict: [String: Any]) {
        scrollView.refreshControl?.endRefreshing()
        
        if let new_confirmed: Int = statsDict["new_confirmed"] as? Int {
            self.LabelCasConfirmesOneNb.text = String(new_confirmed)
        }
        if let new_recovered: Int = statsDict["new_recovered"] as? Int {
            self.LabelGuerisOneNb.text = String(new_recovered)
        }
        if let new_death: Int = statsDict["new_death"] as? Int {
            self.LabelDecesOneNb.text = String(new_death)
        }
        
        if let confirmed: Int = statsDict["confirmed"] as? Int {
            self.LabelCasConfirmesTwoNb.text = String(confirmed)
        }
        if let covered: Int = statsDict["covered"] as? Int {
            self.LabelGuerisTwoNb.text = String(covered)
        }
        if let death: Int = statsDict["death"] as? Int {
            self.LabelDecesTwoNb.text = String(death)
        }
        if let regions: [Dictionary<String,Any>] = statsDict["regions"] as? [Dictionary<String,Any>] {
            self.dataRegions = regions
            self.TableViewHeight.constant = CGFloat(self.statsCellHeight * self.dataRegions.count)
            self.TableViewRegion.reloadData()
        }
    }
    
}



extension StatisticsPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataRegions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath)
        let region = dataRegions[indexPath.row]
        let nbLabel = cell.viewWithTag(100) as! UILabel
        nbLabel.text = region["total"] as! String
        
        let titleLabel = cell.viewWithTag(50) as! UILabel
        var regionStr = region["region"] as! String
        regionStr = regionStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if LanguageManager.currentLanguage() == "ar" {
            if let regionStrAr = RegionsConstants.regionsDict[regionStr] {
                regionStr = regionStrAr
            }
        }
        titleLabel.text = regionStr
        
        let contentStack = cell.viewWithTag(150)
        contentStack!.layer.cornerRadius = 7.0
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.statsCellHeight)
    }
}
