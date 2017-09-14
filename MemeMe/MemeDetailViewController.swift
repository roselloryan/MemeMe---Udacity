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
        
        let editVC = storyboard?.instantiateViewController(withIdentifier: kEditorVCStoryboardID) as! MainVC
    
        editVC.meme =  meme
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    
}
