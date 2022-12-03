//
//  AppDelegate.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/24.
//

import CoreData
import UIKit
import CoreLocation
import MapKit
import GoogleMobileAds
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var locationManager: CLLocationManager!
    private var dataStore: DataStore!
    private var memoList: [Memo]?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // トラッキングの許可
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                // AdMobの初期化
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            })

            // 通知許可の取得
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]) { (granted, _) in
                    if granted {
                        UNUserNotificationCenter.current().delegate = self
                    }
                }
        }

        dataStore = DataStore()
        memoList = dataStore.loadMemo()

        locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LocationNote")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

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

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // アプリが終了（キル）される前
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
}

// MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .list])
    }
}

// MARK: CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        memoList = dataStore.loadMemo()
        didUpdateLocations(location: locValue)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:\(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .restricted {
            print("機能制限している")
        } else if status == .denied {
            print("許可していない")
        } else if status == .authorizedWhenInUse {
            print("このアプリ使用中のみ許可している")
        } else if status == .authorizedAlways {
            print("常に許可している")
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
}

// MARK: ピンとの距離判定
extension AppDelegate {
    // 近いピンがあるか判定を行う
    private func didUpdateLocations(location: CLLocationCoordinate2D) {
        guard let memoList =  memoList else {
            return
        }

        if memoList.count == 0 {
            return
        }

        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        memoList.forEach { memo in
            let memoLocation = CLLocation(latitude: memo.latitude, longitude:
                    memo.longitude)
            let distance = clLocation.distance(from: memoLocation)

            if (distance < MainViewModel.DETERMINE_AREA) && memo.isSendNotice {
               onDeterminedArea(memo: memo)
            }
        }
    }

    private func onDeterminedArea(memo: Memo) {
        var memo = memo
        // 最後に通知を出したのが12時間前であれば通知を出す
        if Date().compare(Calendar.current.date(byAdding: .hour, value: 12, to: memo.lastNoticeDate)!) == ComparisonResult.orderedDescending {
            createUserNotificationRequest(memo: memo)
            // 最終通知表示時間を更新
            memo.lastNoticeDate = Date()
            dataStore.editMemo(memo: memo)
        }
    }

    private func createUserNotificationRequest(memo: Memo) {
       let notificationContent = UNMutableNotificationContent()
       notificationContent.title = memo.title
        notificationContent.body = memo.detail
       notificationContent.sound = UNNotificationSound.default

       let request = UNNotificationRequest(identifier: "LocationNote", content: notificationContent, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
   }
}
