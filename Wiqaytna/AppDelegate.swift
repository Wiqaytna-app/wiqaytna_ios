import UIKit
import UserNotifications

import CoreData
import Firebase
import FirebaseMessaging
import FirebaseAuth
import FirebaseInstanceID
import FirebaseRemoteConfig
import FirebaseFunctions
import CoreMotion
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var pogoMM: PogoMotionManager!
    let gcmMessageIDKey = "gcm.message_id"
    
    static let lastUpdateStatsKey = "lastUpdateStatsKey"
    static var statsDict: [String: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localized()
        
        self.configureFireBaseAndnotifications(application: application)
        
        //configure the database manager
        self.configureDatabaseManager()
        
        self.setupConfigs()
        navigateToCorrectPage()
        self.fetchStatsData()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let userDefaults = UserDefaults.standard
        if let lastUpdateStatsDate: Date = userDefaults.object(forKey: AppDelegate.lastUpdateStatsKey) as? Date {
            
            let currenteDate: Date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour], from: lastUpdateStatsDate, to: currenteDate)
            let difference = components.hour!
            if difference > 3 {
                self.fetchStatsData()
            }
        }
    }
    
    private func configureFireBaseAndnotifications(application: UIApplication) {
        
        FirebaseApp.configure()
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        // Reset Language
        //        UpdateLanguage.setArabicLangue()
        
        //get application instance ID
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey: "firebaseToken")
            }
        }
    }
    
    private func setupConfigs() {
        
        //the below can be in a single configure method inside the BluetraceManager
        let bluetoothAuthorised = BluetraceManager.shared.isBluetoothAuthorized()
        if  OnboardingManager.shared.completedBluetoothOnboarding && bluetoothAuthorised {
            BluetraceManager.shared.turnOn()
        } else {
            print("Onboarding not yet done.")
        }
        
        EncounterMessageManager.shared.setup()
        UIApplication.shared.isIdleTimerDisabled = true
        
        BlueTraceLocalNotifications.shared.initialConfiguration()
        
        // setup pogo mode
        pogoMM = PogoMotionManager(window: self.window)
        
        // Remote config setup
        _ = TracerRemoteConfig()
        
        if !OnboardingManager.shared.completedIWantToHelp {
            do {
                try Auth.auth().signOut()
            } catch {
                Logger.DLog("Unable to signout")
            }
        }
    }
    
    private func fetchStatsData() {
        
        let userDefaults = UserDefaults.standard
        StatisticsServices.statistics { (statsDict) in
            if let _ = statsDict["new_confirmed"] {
                AppDelegate.statsDict = statsDict
                userDefaults.set(Date(), forKey: AppDelegate.lastUpdateStatsKey)
            }
        }
    }
    
    func navigateToCorrectPage() {
        
        let lang = LanguageManager.currentLanguage()
        if !(lang == "ar" || lang == "fr") {
            LanguageManager.setCurrentLanguage("ar")
        }

        let navController = self.window!.rootViewController! as! UINavigationController
        let storyboard = navController.storyboard!
        
        let launchVCIdentifier = OnboardingManager.shared.returnCurrentLaunchPage()
        let vc = storyboard.instantiateViewController(withIdentifier: launchVCIdentifier)
        navController.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "tracer")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func configureDatabaseManager() {
        DatabaseManager.shared().persistentContainer = self.persistentContainer
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.DLog("applicationDidBecomeActive")
        pogoMM.startAccelerometerUpdates()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.DLog("applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.DLog("applicationDidEnterBackground")
        
        let magicNumber = Int.random(in: 0 ... PushNotificationConstants.dailyRemPushNotifContents.count - 1)
        pogoMM.stopAllMotion()
        
        BlueTraceLocalNotifications.shared.removePendingNotificationRequests()
        
        if LanguageManager.currentLanguage() == "ar" {
            BlueTraceLocalNotifications.shared.triggerCalendarLocalPushNotifications(pnContent: PushNotificationConstants.dailyRemPushNotifContentsAR[0], identifier: "appBackgroundNotifId")
        }else {
            BlueTraceLocalNotifications.shared.triggerCalendarLocalPushNotifications(pnContent: PushNotificationConstants.dailyRemPushNotifContents[magicNumber], identifier: "appBackgroundNotifId")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.DLog("applicationWillEnterForeground")
        pogoMM.stopAllMotion()
        BluetraceUtils.removeData21DaysOld()
        
        BlueTraceLocalNotifications.shared.removePendingNotificationRequests()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.DLog("applicationWillTerminate")
        pogoMM.stopAllMotion()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // FIREBASE MESSAGIN: - Receive notifications
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}