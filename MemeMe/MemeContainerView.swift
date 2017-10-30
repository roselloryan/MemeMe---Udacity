import UIKit

class MemeContainerView: UIView {

    
    var customScrollView: CustomScrollView!

    func memeImage() -> UIImage? {
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return memeImage
    }
    
    func addCustomScrollViewWithImage(_ image: UIImage) {
        
        let scrollView = CustomScrollView.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.black
        scrollView.tag = 1
        
        self.insertSubview(scrollView, at: 0)
        scrollView.displayImage(image)
        
        customScrollView = scrollView
        print(self.frame)
        
    }
    
    func removeCustomScrollView() {
        for subview in self.subviews {
            if subview.tag == 1 {
                subview.removeFromSuperview()
            }
        }
    }
}
