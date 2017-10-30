import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes = [Meme]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
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

