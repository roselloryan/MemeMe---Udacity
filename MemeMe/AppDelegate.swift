import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes = [Meme]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        UILabel.appearance().defaultFontName = kdefaultFontName
//        UILabel.appearance(whenContainedInInstancesOf: [PickerVC.self]).defaultFontName = kdefaultFontName
        
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let rootTabBarController = window?.rootViewController as? UITabBarController {
                if let realTabBarItems = rootTabBarController.tabBar.items {
                    for item in realTabBarItems {
                        item.imageInsets = UIEdgeInsets.zero
                    }
                }
            }
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.init(name: kdefaultFontName, size: 17)!], for: UIControlState.normal)
        
        //creatMemeData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func createMemeData() {
       for i in 1...36 {
           if let newImage = UIImage(named: "\(i)") {

            let meme = Meme.init(topText: "\(i)", bottomText: "\(i)", originalImage: newImage, memedImage: newImage, fontName: kdefaultFontName, imageOffset: CGPoint.zero, zoomScale: 1.0)
               memes.append(meme)
           }
       }
    }
    
}

