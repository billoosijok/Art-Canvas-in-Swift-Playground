import UIKit




// MARK: Enums
/**
 Includes: `.top`, `.right`, `.bottom`, `.left`, `.all`
 */
public enum Side {
    case top, right, bottom, left, all
}

// MARK: Functions

/**
 Adds a border to a View, a border can be one-sided or around all sides.
 
 - parameter view: The view.
 - parameter side: The side on which you want the border to be. Possible values: `.top`,`.right`,`.bottom`,`.left`,`.all`.
 - parameter width: The width of the border.
 - parameter color: The color of the border.
 */
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

/**
 Creates a `UIColor` using rgb values. The values must be in range of 0 - 255.
 
 - parameter red: The red value.
 - parameter green: The green value.
 - parameter blue: The blue value
 
 - returns : `UIColor` object.
 */
public func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
}

/**
 Creates a `UIColor` using rgb values. The values must be in range of 0 - 255, except for the `alpha` as it ranges from 0 - 1.
 
 - parameter red: The red value.
 - parameter green: The green value.
 - parameter blue: The blue value
 - parameter alpha: The alpha value
 
 - returns : `UIColor` object.
 
 */
public func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

/**
 Checks if a point is inside a rectangle.
 
 - parameter point: The Point.
 - parameter rect: The Rectangle
 
 - returns : `true` if the point is within, or `false` if not.
 
 */
public func pointIsWithin(point: CGPoint, rect: CGRect) -> Bool {
    
    let rectXExtention = rect.origin.x + rect.width
    let rectYExtention = rect.origin.y + rect.height
    
    if (point.x < rectXExtention
        && point.x > rect.origin.x)
        
        && (point.y < rectYExtention
            && point.y > rect.origin.y) {
        
        return true
    }
    
    return false
}

