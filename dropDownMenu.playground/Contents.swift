//: Playground - noun: a place where people can play

import UIKit



struct MenuItem {
    var view: UIView?
    var size: CGSize?
    
    init(withView view: UIView, ofSpecificSize size: CGSize) {
        
        self.size = size
        self.view = view
        
    }
    
    init(withView view: UIView) {
        
    }
}

class DropDownMenu: UIView {
    
    var menuItems = [MenuItem]()
    var selectedItem : MenuItem?
    
    init(atPosition position: CGPoint, withMenuItems items: [MenuItem]) {
        self.menuItems = items
        
        let menuSize = configMenuSize(menuItems: items)
        super.init(frame: CGRect(origin: position, size: menuSize))
        
        setupItems()
    }
    
    private func setupItems() {
        for i in 0..<menuItems.count {
            
            menuItems[i].view!.isUserInteractionEnabled = false
            menuItems[i].view!.frame.origin = CGPoint(x: 0, y: 0)
            
            let itemSize = menuItems[i].view!.frame.size
            let itemPosition = CGPoint(x: 0, y: itemSize.height*CGFloat(i))
            
            let itemButton = UIButton(frame: CGRect(origin: itemPosition, size: itemSize))
            itemButton.addSubview(menuItems[i].view!)
            itemButton.addTarget(self, action: #selector(menuItemTapped(sender:)), for: .touchUpInside)
        
            self.addSubview(itemButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func menuItemTapped(sender: UIButton) {
        
    }
}

internal func configMenuSize(menuItems items: [MenuItem]) -> CGSize {
    var menuSize = CGSize(width: 0, height: 0)
    
    for item in items {
        if menuSize.width < item.view!.frame.size.width {
            menuSize.width = item.view!.frame.size.width
        }
        
        if menuSize.height < item.view!.frame.size.height {
            menuSize.height = item.view!.frame.size.height
        }
    }
    
    return menuSize
}
