import UIKit




// MARK: Enums
public enum Side {
    case top, right, bottom, left, all
}

// MARK: Functions
public func addBorder(to view: UIView, on side: Side, ofWidth width: CGFloat, andColor color: UIColor) {
    
    let border = CALayer()
    border.frame = view.frame
    border.backgroundColor = color.cgColor;
    
    switch side {
    case .right:
        border.frame.size.width = width;
        border.frame.origin.x = view.frame.origin.x + view.frame.width - width
        break
        
    case .bottom:
        border.frame.size.height = width;
        border.frame.origin.y = view.frame.origin.y + view.frame.height - width
        break
        
    case .left:
        border.frame.size.width = width;
        break
        
    case .top:
        border.frame.size.height = width;
        break
        
    default:
        view.layer.borderWidth = width;
        view.layer.borderColor = color.cgColor;
    }
    
    view.layer.addSublayer(border)
}

public func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
}

public func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}
