import UIKit

private let reuseIdentifier = "memeCollectionViewCell"


class MemeCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var itemsPerRow: CGFloat = 3.0
    var memes: [Meme]!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let spacing: CGFloat = flowLayout.sectionInset.left
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        let dimension = self.view.frame.size.width / itemsPerRow - (2 * spacing)
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView!.reloadData()
    
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Get memes from app delegate.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes = appDelegate.memes
        
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MemeCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
    
        let meme = memes[indexPath.row]
        
        cell.imageView.image = meme.memedImage
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get meme
        let meme = memes[indexPath.row]
        
        // Create detailVC
        let detailVC = storyboard!.instantiateViewController(withIdentifier: kDetailVCstoryboardID) as! MemeDetailViewController
        
        // set meme property on detailVC
        detailVC.meme = meme
        
        // Present detailVC using navigation controller
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }

}
