
import UIKit

/**
 The Popup class it helpful for showing popups in a UIView.
 You can create the popup and show it by calling `show` and hide it by calling `hide`.
 
 The popup has the following default properties: 
 - Text Alignment center.
 - Font Type: System-Thin.
 - Font Color: rgb(150,150,150)
 - Font Size: adjusts to the width of the popup.
 */
public class Popup: UILabel {
    
    var isShowing = false
    
    public init(withText text: String, ofFontSize fontSize: CGFloat) {
        super.init(frame: CGRect())
        
        self.text = text
        self.textAlignment = .center
        self.font = UIFont(name: "System-Thin", size: fontSize)
        self.textColor = rgb(150,150, 150)
        self.adjustsFontSizeToFitWidth = true
        self.isUserInteractionEnabled = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Shows the popup at the specified position.
     
     - parameter position: The `CGPoint` of the position you want the popup 
                            to show up at.
     */
    public func show(atPosition position: CGPoint) {
        
        self.center = position
        self.frame.origin.y += 10
        self.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.frame.origin.y -= 5
            self.alpha = 1
            
        })
        
        isShowing = true
    }
    
    /**
     Hides the popup.
     */
    public func hide() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.frame.origin.y -= 5
            self.alpha = 0
            
        }, completion: {(_: Bool) in
            
            self.removeFromSuperview()
            
        })
        
        isShowing = false
    }
    
    /**
     Shows the popups for a specific duration.
     */
    public func showWithTimer(atPosition position: CGPoint, duration: TimeInterval) {
        self.show(atPosition: position)
        
        perform(#selector(self.hide), with: nil, afterDelay: duration)
    }
    
    /**
     Hides the popup after the specified duration.
     */
    public func hideAfter(duration: TimeInterval) {
        perform(#selector(self.hide), with: nil, afterDelay: duration)
    }
    
    /**
     Changes the text of the popup.
     */
    public func changeText(to newText: String) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: {(_: Bool) in
            
            self.text = newText
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
            })
        })
    }
}
