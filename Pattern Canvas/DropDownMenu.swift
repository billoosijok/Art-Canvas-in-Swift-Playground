//: Playground - noun: a place where people can play

import UIKit


/**
 Creates a drop down menu using an array of `struct MenuItem` as its items.
 Note that the width and height of the menu is baed on the size of the largest menu item.
 */
public class DropDownMenu: UIView {
    
    // MARK: Properties
    public var menuItems = [MenuItem]()
    public var selectedItem : MenuItem?
    
    public var toggleButton: UIButton?
    public var isMenuOn: Bool = false
    
    public var smallSize = CGSize() // The menu's size when shrunk
    public var fullSize = CGSize() // The menu's size when opened
    
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
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        // Aligning the arrow icon
        toggleButton!.imageEdgeInsets.right = toggleButton!.frame.width/2 * 0.75 * 0.05
        toggleButton!.imageEdgeInsets.left = toggleButton!.frame.width/2 * 0.75 * 2.06
        toggleButton!.imageEdgeInsets.top = toggleButton!.frame.height/2 * 0.75
        toggleButton!.imageEdgeInsets.bottom = toggleButton!.frame.height/2 * 0.75
        
        // So that the icon image doesn't get distorted
        toggleButton?.imageView?.contentMode = .scaleAspectFit
        
        // Finally adding to the menu
        self.addSubview(toggleButton!)
    }
    
    
    func menuToggleTapped(sender: UIButton) {
        if !isMenuOn { toggle(.on) }
            
        else { toggle(.off) }
    }
    
    /*
     Toggles the menu `on` or `off`
     
     - parameter state: `on` or `off`.
     **/
    public func toggle(_ state: State) {
        
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
        
        // The assignment is only to avoid the complier warning
        let _ = select(itemNumber: Int(sender.restorationIdentifier!)!)
    }
    
    /**
     Selects an item in the menu. If the passed item position is invalid/out of range, it returns `false`
     
     - parameter number: The number of the item in the menu. The first being 0.
     
     - return: `false` if the number passed is out of range, or `true` if it succeeded
     */
    public func select(itemNumber number: Int) -> Bool {
        
        // Making sure the the number passed is not out of range
        if number >= self.menuItems.count {
            return false
        }
        
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
        
        // It's a success! So we return true.
        return true
        
    }
    
}

/**
 A Structure that creates a menu item for the dropdown menu.
 The properties are:
 - view : The View you want to represent the menu item with
 - size : The size of the item as CGSize
 - value: The value associated with the menu option (useful when selecting it)
 */
public struct MenuItem {
    public var view: UIView
    public var size: CGSize
    public var value: AnyObject
    
    /**
     This creates a menu item using the view that gets passed.
     
     - parameter view : The view of the menu item.
     - parameter value: The value you want to be associated with the item.
     - parameter size : The size of the menu item.
     */
    public init(withView view: UIView, value: AnyObject, ofSpecificSize size: CGSize) {
        
        // To reset position of the view
        view.frame.origin = CGPoint(x: 0, y: 0)
        
        // Setting up properties
        self.view = view
        self.value = value
        self.size = size
    }
    
    /**
     This creates a menu item using the view that gets passed. Also it uses the frame of the passed view for its size.
     
     - parameter view : The view of the menu item.
     - parameter value: The value you want to be associated with the item.
     
     */
    public init(withView view: UIView, value: AnyObject) {
        self.init(withView: view, value: value, ofSpecificSize: view.frame.size)
    }
    
    /**
     This makes it easy to create a text-based menu item by just passing a string instead of a view.
     
     - parameter text : The text of the menu item.
     - parameter value: The value you want to be associated with the item.
     - parameter size : The size of the menu item.
     */
    public init(withText text: String, value: AnyObject, andFrameSize size: CGSize) {
        
        // Creating the label that will hold the text.
        let label = UILabel(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        label.text = text
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        let view = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        view.addSubview(label)
        
        self.init(withView: view, value: value, ofSpecificSize: size)
    }
}

/**
 This function helps class DropDownMenus calculate its size based
 on the items passed to it. This needs to be outside the class, because
 it need to be called even before super.init
 */
internal func configMenuSize(menuItems items: [MenuItem]) -> CGSize {
    
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
