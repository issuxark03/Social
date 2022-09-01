//
//  AppDelegate.swift
//  Social
//
//  Created by Yongwoo Yoo on 2022/05/18.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        
//        db.collection("feedList").getDocuments { snapshot, _ in
//            guard snapshot?.isEmpty == true else { return }
//            let batch = db.batch()
//
//            let card0Ref = db.collection("feedList").document("card0")
//
//            db.collection("feedList")
//            do {
//                try batch.setData(from: FeedDummy.card0, forDocument: card0Ref)
//            } catch let error {
//                print("Error writing city to Firestore: \(error)")
//            }
//
//            batch.commit() { err in
//                if let err = err {
//                    print("Error writing batch \(err)")
//                } else {
//                    print("Batch write succeeded.")
//                }
//            }
//        }
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


}

