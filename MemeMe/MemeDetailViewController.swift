import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = meme.memedImage
     }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editBarButtonTapped))
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func editBarButtonTapped(_ sender: UIBarButtonItem) {
        print("YAY!")
        
        ((tabBarController?.viewControllers?.last as! UINavigationController).viewControllers.first! as! MainVC).meme = meme
        ((tabBarController?.viewControllers?.last as! UINavigationController).viewControllers.first! as! MainVC).selectedImage = meme.originalImage
        
        tabBarController?.animateToTab(toIndex: tabBarController!.viewControllers!.count - 1)
        tabBarController!.selectedIndex = tabBarController!.viewControllers!.count - 1
    }
    
}
