//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


struct MenuItem {
    var view: UIView
    var size: CGSize
    var value: Any
    
    init(withView view: UIView, value: Any, ofSpecificSize size: CGSize) {
        // To reset position
        view.frame.origin = CGPoint(x: 0, y: 0)
    
        self.view = view
        self.value = value
        self.size = size
    }
    
    init(withView view: UIView, value: Any) {
        self.init(withView: view, value: value, ofSpecificSize: view.frame.size)
    }
    
    init(withText text: String, value: Any, andFrameSize size: CGSize) {
        
        let label = UILabel(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        label.text = text
        label.textAlignment = .center
        
        let view = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        view.addSubview(label)
        
        self.init(withView: view, value: value, ofSpecificSize: size)
    }
}

class DropDownMenu: UIView {
    
    var toggleButton: UIButton?
    var isMenuOn: Bool = false
    var menuItems = [MenuItem]()
    var selectedItem : MenuItem?
    var smallSize = CGSize()
    var fullSize = CGSize()
    
    init(atPosition position: CGPoint, withMenuItems items: [MenuItem]) {
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
            
            menuItems[i].view.isUserInteractionEnabled = false
            menuItems[i].view.frame.origin = CGPoint(x: 0, y: 0)
            
            let itemSize = menuItems[i].view.frame.size
            let itemPosition = CGPoint(x: 0, y: itemSize.height*CGFloat(i))
            
            let itemButton = UIButton(frame: CGRect(origin: itemPosition, size: itemSize))
            
            if i != 0 { itemButton.center.x = self.center.x }
            
            itemButton.restorationIdentifier = "\(i)"
            itemButton.addSubview(menuItems[i].view)
            itemButton.addTarget(self, action: #selector(menuItemTapped(sender:)), for: .touchUpInside)
            
            self.addSubview(itemButton)
            
            // The full height will be the height of all the buttons combined
            self.fullSize.height += itemButton.frame.size.height
        }
        
        selectedItem = menuItems[0]
        
        toggleButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.smallSize))
        toggleButton!.setImage(#imageLiteral(resourceName: "arrowDown.png"), for: .normal)
        toggleButton!.setImage(#imageLiteral(resourceName: "arrowDown-on.png"), for: .highlighted)
        
        toggleButton!.imageEdgeInsets.right = toggleButton!.frame.width/2 * 0.75 * 0.05
        toggleButton!.imageEdgeInsets.left = toggleButton!.frame.width/2 * 0.75 * 2.06
        toggleButton!.imageEdgeInsets.top = toggleButton!.frame.height/2 * 0.75
        toggleButton!.imageEdgeInsets.bottom = toggleButton!.frame.height/2 * 0.75
        
        toggleButton?.imageView?.contentMode = .scaleAspectFit
        
        
        toggleButton!.addTarget(self, action: #selector(menuToggleTapped), for: .touchUpInside)
        
        self.addSubview(toggleButton!)
        toggleButton!.imageView?.frame.size.width = 50
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func menuToggleTapped(sender: UIButton) {
        toggle()
    }
    
    func toggle() {
        
        if !isMenuOn {
            /* Toggle on */
            isMenuOn = true
            
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.size.height = self.fullSize.height
            })
            
            for i in 0..<self.menuItems.count {
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
            
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.size.height = self.smallSize.height
            })
            
            for i in 0..<self.menuItems.count {
                if i != 0 {
                    let button = self.menuItems[i].view.superview!
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        button.frame.origin.y -= 10
                    }, completion: {(_: Bool) in
                    
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
        
        // This is the gap left after moving the selected item to the top
        var gapLeft: CGFloat = 0
        
        for i in 0..<self.menuItems.count {
        
            if i == selectedItemPosition {
                /* This when the loop reaches the item selected */
                selectedItemButton.restorationIdentifier = "0"
                
                if selectedItemButton.frame.origin.y != 0 {
                    gapLeft = selectedItemButton.frame.height
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    selectedItemButton.frame.origin.y = 0
                    selectedItemButton.frame.origin.x = 0
                })
            }
        }
        
        for i in 0..<self.menuItems.count {
            if i < selectedItemPosition {
                /* This is if the menu item is above the selected item */
                
                let itemButton = menuItems[i].view.superview as! UIButton
                itemButton.restorationIdentifier = "\(i+1)"
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    itemButton.frame.origin.y += gapLeft
                    itemButton.center.x = self.center.x
                    
                })
            }
        }
        
        menuItems.insert(menuItems.remove(at: selectedItemPosition), at: 0)
        selectedItem = selectedMenuItem
        
        
        toggle()
    }
}

internal func configMenuSize(menuItems items: [MenuItem]) -> CGSize {
    var menuSize = CGSize(width: 0, height: 0)
    
    for item in items {
        if menuSize.width < item.view.frame.size.width {
            menuSize.width += item.view.frame.size.width
        }
        
        if menuSize.height < item.view.frame.size.height {
            menuSize.height += item.view.frame.size.height
        }
    }
    
    return menuSize
}


let optionSize = CGSize(width: 120, height: 50)
let options = [ "Go Away", "Nice", "Click", "Go Away", "Nice","Click", "Go Away", "Nice"];

let shape = UIView(frame: CGRect(x: 0, y:0, width: optionSize.width/2, height: optionSize.height/2))
shape.backgroundColor = UIColor.green
let shapeOption = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: optionSize))
shapeOption.backgroundColor = UIColor.white
shape.center = shapeOption.center

shapeOption.addSubview(shape)

var menuItems = [MenuItem]()

for i in options {
    menuItems.append(MenuItem(withText: i, value: i, andFrameSize: optionSize))
}

menuItems.append(MenuItem(withView: shapeOption, value: shape))


let dropDown = DropDownMenu(atPosition: CGPoint(x: 0, y: 0), withMenuItems: menuItems)
dropDown.backgroundColor = UIColor.white

let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 500))
view.backgroundColor = UIColor.red
view.addSubview(dropDown)

PlaygroundPage.current.liveView = view
