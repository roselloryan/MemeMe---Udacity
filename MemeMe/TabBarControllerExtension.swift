import UIKit

extension UITabBarController {
    
    func animateToTab(toIndex: Int) {
        let tabViewControllers = self.viewControllers!
        let fromView = self.selectedViewController!.view!
        let toView = tabViewControllers[toIndex].view!
        let fromIndex = self.selectedIndex
        
        guard fromIndex != toIndex else {return}
        
        // Add the toView to the tab bar view
        fromView.superview!.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width;
        let scrollRight = toIndex > fromIndex;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            // Slide the views by -offset
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
            
            
            // Animate tab bar out or in if coming to or from mainVC editor
            if toIndex == 2 {
                self.tabBar.frame = CGRect(x: -self.tabBar.frame.width, y: self.tabBar.frame.origin.y, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
            }
            else if fromIndex == 2 {
                self.tabBar.frame = CGRect(x: 0, y: self.tabBar.frame.origin.y, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
            }
            
        }, completion: { finished in
            
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
}
