//: Playground - noun: a place where people can play

import UIKit

public struct MenuItem {
    public var view: UIView
    public var size: CGSize
    public var value: AnyObject
    
    public init(withView view: UIView, value: AnyObject, ofSpecificSize size: CGSize) {
        // To reset position
        view.frame.origin = CGPoint(x: 0, y: 0)
        
        self.view = view
        self.value = value
        self.size = size
    }
    
    public init(withView view: UIView, value: AnyObject) {
        self.init(withView: view, value: value, ofSpecificSize: view.frame.size)
    }
    
    public init(withText text: String, value: AnyObject, andFrameSize size: CGSize) {
        
        let label = UILabel(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        label.text = text
        label.textAlignment = .center
        
        let view = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        view.addSubview(label)
        
        self.init(withView: view, value: value, ofSpecificSize: size)
    }
}

public class DropDownMenu: UIView {
    
    public var toggleButton: UIButton?
    public var isMenuOn: Bool = false
    public var menuItems = [MenuItem]()
    public var selectedItem : MenuItem?
    var smallSize = CGSize()
    var fullSize = CGSize()
    
    public var onChange = {}
    
    public enum State {
        case on, off
    }
    
    public init(atPosition position: CGPoint, withMenuItems items: [MenuItem]) {
        self.menuItems = items
        
        self.smallSize = configMenuSize(menuItems: items)
        
        // Adding a margin for the toggle
        self.smallSize.width += 20
        
        // So far we know the width of the largest menu item
        // so we use that to set the fullsize
        self.fullSize.width = self.smallSize.width
        
        super.init(frame: CGRect(origin: position, size: self.smallSize))
        
        self.clipsToBounds = true
        
        setupItems()
    }
    
    private func setupItems() {
        
        for i in 0..<menuItems.count {
            
            // That's so that it doesn't manage touches
            menuItems[i].view.isUserInteractionEnabled = false
            
            // Resetting just in case
            menuItems[i].view.frame.origin = CGPoint(x: 0, y: 0)
            
            // Creating the item button
            let itemSize = menuItems[i].view.frame.size
            let itemPosition = CGPoint(x: 0, y: itemSize.height*CGFloat(i))
            let itemButton = UIButton(frame: CGRect(origin: itemPosition, size: itemSize))
            
            
            // Setting up the button
            // the ID is used to know the position of the button in the menu
            itemButton.restorationIdentifier = "\(i)"
            itemButton.addSubview(menuItems[i].view)
            itemButton.addTarget(self, action: #selector(menuItemTapped(sender:)), for: .touchUpInside)
            // This centers all menu items except the first one
            if i != 0 { itemButton.center.x = self.center.x }
            
            self.addSubview(itemButton)
            
            // The full height will be the height of all the buttons combined
            self.fullSize.height += itemButton.frame.size.height
        }
        
        // Initial Select
        select(itemNumber: 0)
        
        // The Toggle Button of the menu
        toggleButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.smallSize))
        toggleButton!.addTarget(self, action: #selector(menuToggleTapped), for: .touchUpInside)
        
        // This is the arrow icon
        toggleButton!.setImage(UIImage(named: "arrowDown"), for: .normal)
        toggleButton!.setImage(UIImage(named: "arrowDown-on"), for: .highlighted)
        
        // Aligning the icon
        toggleButton!.imageEdgeInsets.right = toggleButton!.frame.width/2 * 0.75 * 0.05
        toggleButton!.imageEdgeInsets.left = toggleButton!.frame.width/2 * 0.75 * 2.06
        toggleButton!.imageEdgeInsets.top = toggleButton!.frame.height/2 * 0.75
        toggleButton!.imageEdgeInsets.bottom = toggleButton!.frame.height/2 * 0.75
        
        // So that the icon image doesn't get distorted
        toggleButton?.imageView?.contentMode = .scaleAspectFit
        
        // Finally adding to the menu
        self.addSubview(toggleButton!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func menuToggleTapped(sender: UIButton) {
        if !isMenuOn { toggle(.on) }
            
        else { toggle(.off) }
    }
    
    func toggle(_ state: State) {
        
        if state == .on && !isMenuOn {
            /* Toggle on */
            
            isMenuOn = true
            
            // Opening up the menu to the full size
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.size.height = self.fullSize.height
            })
            
            // This is only for the 'Epic Enrances'.
            for i in 0..<self.menuItems.count {
                /* Only the items that are not the first*/
                if i != 0 {
                    
                    let button = self.menuItems[i].view.superview!
                    button.frame.origin.y -= 10
                    
                    UIView.animate(withDuration: 0.1 + Double(i)/18.0, animations: {
                        button.frame.origin.y += 10
                    });
                }
            }
        } else {
            /* Toggle off */
            
            isMenuOn = false
            
            // Closing up the menu to the full size
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.size.height = self.smallSize.height
            })
            
            // Again, 'The Epic Exit'
            for i in 0..<self.menuItems.count {
                if i != 0 {
                    let button = self.menuItems[i].view.superview!
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        button.frame.origin.y -= 10
                        button.alpha = 0
                    }, completion: {(_: Bool) in
                        // to reset
                        button.alpha = 1
                        button.frame.origin.y += 10
                    });
                }
            }
        }
    }
    
    func menuItemTapped(sender: UIButton) {
        select(itemNumber: Int(sender.restorationIdentifier!)!)
    }
    
    func select(itemNumber number: Int) {
        
        // Because all items are contained in UIButtons
        let selectedMenuItem = menuItems[number]
        let selectedItemButton = selectedMenuItem.view.superview as! UIButton
        let selectedItemPosition = number
        
        // This will be the gap left after moving the selected item to the top
        var gapLeft: CGFloat = 0
        
        for i in 0..<self.menuItems.count {
            
            /* This when the loop reaches the item selected */
            if i == selectedItemPosition {
                
                // Setting the selected item to have the ID of 0
                selectedItemButton.restorationIdentifier = "0"
                
                // if the y is 0 it means the item is already in the top
                if selectedItemButton.frame.origin.y != 0 {
                    gapLeft = selectedItemButton.frame.height
                    
                    // Moving the selected item all the way to top
                    UIView.animate(withDuration: 0.2, animations: {
                        selectedItemButton.frame.origin.y = 0
                        selectedItemButton.frame.origin.x = 0
                    })
                }
            }
        }
        
        /* Here we basically update the items above the selected one */
        for i in 0..<self.menuItems.count {
            
            /* This is if the menu item is above the selected item */
            if i < selectedItemPosition {
                
                // To get a handle of the actual button
                let itemButton = menuItems[i].view.superview as! UIButton
                
                // Updating the ID
                itemButton.restorationIdentifier = "\(i+1)"
                
                // Moving them all down using the 'gepLeft'
                UIView.animate(withDuration: 0.2, animations: {
                    itemButton.frame.origin.y += gapLeft
                    itemButton.center.x = self.center.x
                })
            }
        }
        
    
        // Updating the array of menu items to reflect the changes
        menuItems.insert(menuItems.remove(at: selectedItemPosition), at: 0)
        
        // This is the new selected button
        selectedItem = selectedMenuItem
        
        // Overriding this would provide functionalities onChange
        self.onChange()

        // Finally, we toggle the menu off 🎉
        toggle(.off)
    }
}


internal func configMenuSize(menuItems items: [MenuItem]) -> CGSize {
    /* This function helps the class DropDownMenus calculate its size based
     on the items passed to it. This needs to be outside the class, because
     it gets called even before super.init
     */
    
    // This will simply reflect the size of the largest menu item
    var menuSize = CGSize(width: 0, height: 0)
    
    for item in items {
        
        // Whenever we find a larger item we update the menuSize
        if menuSize.width < item.view.frame.size.width {
            menuSize.width += item.view.frame.size.width
        }
        if menuSize.height < item.view.frame.size.height {
            menuSize.height += item.view.frame.size.height
        }
    }
    
    return menuSize
}


//let optionSize = CGSize(width: 120, height: 50)
//let options = [ "Go Away", "Nice", "Click", "Go Away", "Nice","Click", "Go Away", "Nice"];
//
//let shape = UIView(frame: CGRect(x: 0, y:0, width: optionSize.width/2, height: optionSize.height/2))
//shape.backgroundColor = UIColor.green
//let shapeOption = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: optionSize))
//shapeOption.backgroundColor = UIColor.white
//shape.center = shapeOption.center
//
//shapeOption.addSubview(shape)
//
//var menuItems = [MenuItem]()
//
//for i in options {
//    menuItems.append(MenuItem(withText: i, value: i, andFrameSize: optionSize))
//}
//
//menuItems.append(MenuItem(withView: shapeOption, value: shape))
//
//
//let dropDown = DropDownMenu(atPosition: CGPoint(x: 0, y: 0), withMenuItems: menuItems)
//dropDown.backgroundColor = UIColor.white
//
//let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 500))
//view.backgroundColor = UIColor.red
//view.addSubview(dropDown)
