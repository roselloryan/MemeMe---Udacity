import UIKit

class MemeTableViewController: UITableViewController {
    
    private var reuseIdentifier = "memeTableViewCell"
    
    var memes: [Meme]!


    override func viewDidLoad() {
        super.viewDidLoad()

        memes = (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tabButton = UITabBarItem.init(title: "Table", image: nil, tag: 1)
        tabButton.setTitleTextAttributes([NSFontAttributeName: UIFont.init(name: kdefaultFontName, size: 17)!], for: .normal)
        self.tabBarItem = tabButton
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MemeTableViewCell

        let meme = memes[indexPath.row]
        
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let memedImage = memes[indexPath.row].memedImage
        
        // iWidth / screenWidth =  divisor
        
        return memedImage.size.height / (memedImage.size.width / view.frame.size.width)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get meme
        let meme = memes[indexPath.row]
        
        // Create detailVC
        let detailVC = storyboard!.instantiateViewController(withIdentifier: kDetailVCstoryboardID) as! MemeDetailViewController
        
        // set meme property on detailVC
        detailVC.meme = meme
        // Present detailVC using navigation controller
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // Delete from shared data source
            (UIApplication.shared.delegate as! AppDelegate).memes.remove(at: indexPath.row)
            
            // update tableView data source
            memes = (UIApplication.shared.delegate as! AppDelegate).memes
            
            DispatchQueue.main.async { [unowned self] in
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
