import UIKit
import Lottie
import CoreData
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var screenStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bluetoothStatusOffView: UIView!
    @IBOutlet weak var bluetoothStatusOnView: UIView!
    @IBOutlet weak var bluetoothPermissionOffView: UIView!
    @IBOutlet weak var bluetoothPermissionOnView: UIView!
    @IBOutlet weak var pushNotificationOnView: UIView!
    @IBOutlet weak var pushNotificationOffView: UIView!
    @IBOutlet weak var incompleteHeaderView: UIView!
    @IBOutlet weak var successHeaderView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var powerSaverCardView: UIView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    @IBOutlet weak var HomeWelcome: UILabel!
    @IBOutlet weak var HomeSubWelcome: UILabel!
    
    @IBOutlet weak var ShareAppTitle: UILabel!
    @IBOutlet weak var ShareAppSubTitle: UILabel!
    
    @IBOutlet weak var StatusCasConfirmes: UILabel!
    @IBOutlet weak var StatusGueris: UILabel!
    @IBOutlet weak var StatusDeces: UILabel!
    @IBOutlet weak var HomeBluetoothDisable: UILabel!
    @IBOutlet weak var HomeBluetoothTitleDisable: UILabel!
    
    @IBOutlet weak var BarBottomAccueil: UITabBarItem!
    @IBOutlet weak var BarBottomStatistics: UILabel!
    
    @IBOutlet weak var PermissionBluetoothPOn: UILabel!
    @IBOutlet weak var PermissionBluetoothPOff: UILabel!
    @IBOutlet weak var PermissionBluetoothPActive: UILabel!
    @IBOutlet weak var PermissionBluetoothPDesactive: UILabel!
    @IBOutlet weak var PermissionNotificationsOn: UILabel!
    @IBOutlet weak var PermissionNotificationsOff: UILabel!
    
    @IBOutlet weak var NbCasConfirmes: UILabel!
    @IBOutlet weak var NbGueris: UILabel!
    @IBOutlet weak var NbDeces: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleFAQ: UILabel!
    @IBOutlet weak var textFAQ: UILabel!
    @IBOutlet weak var FAQView: UIView!
    
    
    var fetchedResultsController: NSFetchedResultsController<Encounter>?
    
    var allPermissionOn = true
    var bleAuthorized = true
    var blePoweredOn = true
    var pushNotificationGranted = true
    
    var _preferredScreenEdgesDeferringSystemGestures: UIRectEdge = []
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return _preferredScreenEdgesDeferringSystemGestures
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":6, "screen":"ecran d'accueil"] as [String : Any]
        Analytics.logEvent("home_screen", parameters: _parameters)
        observeNotifications()
        self.setScrollView()
        animationView.loopMode = LottieLoopMode.playOnce
        updateText()
        updateLayout()
        getDataStatistics()
        updateLangueSetting()
        let shareTapGR = UITapGestureRecognizer(target: self, action: #selector(onShareTapped))
        shareView.addGestureRecognizer(shareTapGR)
        let faqTapGR = UITapGestureRecognizer(target: self, action: #selector(onFaqTapped))
        FAQView.addGestureRecognizer(faqTapGR)
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
        UserDefaults.standard.set(true, forKey: "firstLaunch")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.readPermissionsAndUpdateViews()
        self.fetchEncounters()
    }
    
    @objc private func applicationDidBecomeActive() {
        readPermissionsAndUpdateViews()
    }
    
    private func localizeTabBarItems() {
        
        if let tabBarVC: UITabBarController = self.tabBarController {
            let tabBar: UITabBar = tabBarVC.tabBar
            
            tabBar.items![0].title = "BarBottomAccueil".localized()
            tabBar.items![1].title = "BarBottomStatistics".localized()
            tabBar.items![2].title = "BarBottomUpload".localized()
            tabBar.items![3].title = "BarBottomConseils".localized()
        }
        
    }

    private func setScrollView() {
        scrollView.refreshControl = UIRefreshControl.defaultRefreshControl(self, selectorAction: #selector(getDataStatistics))

        scrollView.addSubview(screenStack)
        screenStack.translatesAutoresizingMaskIntoConstraints = false
        screenStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        screenStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        screenStack.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        screenStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        screenStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    @objc func getDataStatistics() {

        if AppDelegate.statsDict != nil {
            self.displayStats(statsDict: AppDelegate.statsDict!)
            return
        }
        self.activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        StatisticsServices.statistics { [weak self] (statsDict) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            if let _ = statsDict["new_confirmed"] {
                AppDelegate.statsDict = statsDict
                self.displayStats(statsDict: statsDict)
                UserDefaults.standard.set(Date(), forKey: AppDelegate.lastUpdateStatsKey)
            }
        }
    }
    
    private func displayStats(statsDict:[String: Any]) {
        scrollView.refreshControl?.endRefreshing()

        if let new_confirmed: Int = statsDict["new_confirmed"] as? Int {
            self.NbCasConfirmes.text = String(new_confirmed)
        }
        if let new_recovered: Int = statsDict["new_recovered"] as? Int {
            self.NbGueris.text = String(new_recovered)
        }
        if let new_death: Int = statsDict["new_death"] as? Int {
            self.NbDeces.text = String(new_death)
        }
        if let date: [String: Any] = statsDict["date"] as? [String: Any] {
            if let _seconds: Int = date["_seconds"] as? Int {
                let _date = Date(timeIntervalSince1970: TimeInterval(_seconds))
                
                self.updateLastUpdatedTime(_date)
            }
            
        }
    }

    func updateLangueSetting(){
        if let _currentLang: String = LanguageManager.currentLanguage() as? String {
            UpdateUser.setUser(age: "", province: "", region: "", gender: "", regionID: "", provinceID: "", lang: _currentLang) { (dataResult,isSuccess) in
                if isSuccess {
                    print(dataResult)
                } else {
                    print(dataResult)
                }
            }
        }
        
    }
    
    @objc func updateText() {
        HomeWelcome.text = "HomeWelcome".localized()
        HomeSubWelcome.text = "HomeSubWelcome".localized()
        ShareAppTitle.text = "ShareAppTitle".localized()
        ShareAppSubTitle.text = "ShareAppSubTitle".localized()
        StatusCasConfirmes.text = "StatusCasConfirmes".localized()
        StatusGueris.text = "StatusGueris".localized()
        StatusDeces.text = "StatusDeces".localized()
        HomeBluetoothDisable.text = "HomeBluetoothDisable".localized()
        BarBottomAccueil.title = "BarBottomAccueil".localized()        
        PermissionBluetoothPOn.text = "PermissionBluetoothP".localized()
        PermissionBluetoothPOff.text = "PermissionBluetoothP".localized()
        PermissionBluetoothPActive.text = "PermissionBluetoothA".localized()
        PermissionBluetoothPDesactive.text = "PermissionBluetoothA".localized()
        PermissionNotificationsOn.text = "PermissionNotifications".localized()
        PermissionNotificationsOff.text = "PermissionNotifications".localized()
        HomeBluetoothTitleDisable.text = "HomeBluetoothTitleDisable".localized()
        BarBottomStatistics.text = "HomeTitleStatistics".localized()
        
        titleFAQ.text = "titleFAQ".localized()
        textFAQ.text = "textFAQ".localized()
        
        self.localizeTabBarItems()
        
        if AppDelegate.statsDict != nil {
            self.displayStats(statsDict: AppDelegate.statsDict!)
        }
        
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
    func updateLayout(){
        if LanguageManager.currentLanguage() == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
    func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableDeferringSystemGestures(_:)), name: .enableDeferringSystemGestures, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableDeferringSystemGestures(_:)), name: .disableDeferringSystemGestures, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableUserInteraction(_:)), name: .disableUserInteraction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableUserInteraction(_:)), name: .enableUserInteraction, object: nil)
    }
    
    private func togglePermissionViews() {
        togglePushNotificationsStatusView()
        toggleBluetoothStatusView()
        toggleBluetoothPermissionStatusView()
        toggleIncompleteHeaderView()
    }
    
    private func readPermissionsAndUpdateViews() {
        
        blePoweredOn = BluetraceManager.shared.isBluetoothOn()
        bleAuthorized = BluetraceManager.shared.isBluetoothAuthorized()
        
        BlueTraceLocalNotifications.shared.checkAuthorization { (pnsGranted) in
            self.pushNotificationGranted = pnsGranted
            
            self.allPermissionOn = self.blePoweredOn && self.bleAuthorized && self.pushNotificationGranted
            if(!self.allPermissionOn){
                let _parameters = ["id":7, "screen":"ecran d'accueil - authorisation manquantes"] as [String : Any]
                Analytics.logEvent("home_screen_setup_incomplete", parameters: _parameters)
            }
            self.togglePermissionViews()
        }
    }
    
    private func toggleIncompleteHeaderView() {
        successHeaderView.isVisible = self.allPermissionOn
        powerSaverCardView.isVisible = self.allPermissionOn
        incompleteHeaderView.isVisible = !self.allPermissionOn
    }
    
    private func toggleBluetoothStatusView() {
        //bluetoothStatusOnView.isVisible = !self.allPermissionOn && self.blePoweredOn
        bluetoothStatusOnView.isVisible = false
        bluetoothStatusOffView.isVisible = !self.allPermissionOn && !self.blePoweredOn
    }
    
    private func toggleBluetoothPermissionStatusView() {
        //bluetoothPermissionOnView.isVisible = !self.allPermissionOn && self.bleAuthorized
        bluetoothPermissionOnView.isVisible = false
        bluetoothPermissionOffView.isVisible = !self.allPermissionOn && !self.bleAuthorized
    }
    
    private func togglePushNotificationsStatusView() {
        //pushNotificationOnView.isVisible = !self.allPermissionOn && self.pushNotificationGranted
        pushNotificationOnView.isVisible = false
        pushNotificationOffView.isVisible = !self.allPermissionOn && !self.pushNotificationGranted
    }
    
    @objc func onShareTapped() {
        let _parameters = ["id":14, "screen":"share the app"] as [String : Any]
        Analytics.logEvent("FirebaseAnalytics.Event.SHARE", parameters: _parameters)
        let shareText = TracerRemoteConfig.instance.configValue(forKey: "ShareText").stringValue ?? TracerRemoteConfig.defaultShareText
        let activity = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = shareView
        
        present(activity, animated: true, completion: nil)
    }
    
    @objc func onFaqTapped() {
        let _parameters = ["id":13, "screen":"click sur FAQ - écran d'accueil"] as [String : Any]
        Analytics.logEvent("open_faq", parameters: _parameters)
        let URLFAQ = "URLFAQ".localized()
        guard let url = URL(string: URLFAQ) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    func enableUserInteraction(_ notification: Notification) {
        self.view.isUserInteractionEnabled = true
    }
    
    @objc
    func disableUserInteraction(_ notification: Notification) {
        self.view.isUserInteractionEnabled = false
    }
    
    @objc
    func enableDeferringSystemGestures(_ notification: Notification) {
        if #available(iOS 11.0, *) {
            _preferredScreenEdgesDeferringSystemGestures = .bottom
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    @objc
    func disableDeferringSystemGestures(_ notification: Notification) {
        if #available(iOS 11.0, *) {
            _preferredScreenEdgesDeferringSystemGestures = []
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    func fetchEncounters() {
        let sortByDate = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchedResultsController = DatabaseManager.shared().getFetchedResultsController(Encounter.self, with: nil, with: sortByDate, prefetchKeyPaths: nil, delegate: self)
        
        do {
            try fetchedResultsController?.performFetch()
            setInitialLastUpdatedTime()
        } catch let error as NSError {
            print("Could not perform fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func setInitialLastUpdatedTime() {
        guard let encounters = fetchedResultsController?.fetchedObjects else {
            return
        }
        guard encounters.count > 0 else {
            return
        }
        let firstEncounter = encounters[0]
        // updateLastUpdatedTime(date: firstEncounter.timestamp!)
    }
    
    func updateLastUpdatedTime(_ date: Date) {
        let formatter = DateFormatter()
        
        if LanguageManager.currentLanguage() == "ar" {
            formatter.locale = Locale(identifier: "ar")
            formatter.dateFormat = "MMM"
            let dayStr = formatter.string(from: date)
            formatter.dateFormat = "d \(dayStr) yyyy الساعة HH"
            formatter.locale = Locale(identifier: "fr")
            self.lastUpdatedLabel.text = "\(formatter.string(from: date))"
        }else {
            
            formatter.dateFormat = "d MMM yyyy HH:mm"
            formatter.locale = Locale(identifier: "fr")
            self.lastUpdatedLabel.text = "\(formatter.string(from: date))"
        }
        
    }
    
    func playActivityAnimation() {
        animationView.play()
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let encounter = anObject as! Encounter
            if ![Encounter.Event.scanningStarted.rawValue, Encounter.Event.scanningStopped.rawValue].contains(encounter.msg) {
                self.playActivityAnimation()
            }
            //self.updateLastUpdatedTime(date: Date())
            break
        default:
            //self.updateLastUpdatedTime(date: Date())
            break
        }
    }
}
