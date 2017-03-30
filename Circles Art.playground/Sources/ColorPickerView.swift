import UIKit

public class colorPickerView: UIScrollView {
    
    public var colors = [UIColor]()
    private var optionSize = CGSize()
    public var optionButtons = [UIButton]()
    public var currentColor = UIColor.red
    private var currentColorIndicator : CurrentColorIndicator?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(frame: CGRect, colors: [UIColor]) {
        super.init(frame: frame)
        
        self.isScrollEnabled = true
        
        let optionSize = CGSize(width: self.frame.height/2, height: self.frame.height/2)
        self.colors = colors
        
        let spacingFactor = max(50, self.frame.width/CGFloat(colors.count))
        
        for i in 0..<colors.count {
            
            let optionFrame = CGRect(origin: CGPoint(x: CGFloat(i) * spacingFactor + (optionSize.width/2), y: self.frame.height/2 - optionSize.height/2), size: optionSize)
            let option = makeColorOption(frame: optionFrame, color: colors[i]);
            
            
            option.addTarget(self, action: #selector(self.optionTapped), for: .touchUpInside)
            
            optionButtons.append(option)
            
            self.addSubview(option);
        }
        
        self.contentSize.width = optionButtons.last!.frame.origin.x + optionSize.width + 30
        
        currentColorIndicator = CurrentColorIndicator(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: optionSize.width + 10, height: optionSize.height + 10)))
        
        self.addSubview(currentColorIndicator!)
        
        setCurrentColor(optionButton: optionButtons.first!)
        
    }
    
    public func setCurrentColor(optionButton: UIButton) {
        changeColor(to: optionButton.backgroundColor!)
        selectButton(button: optionButton)
    }
    
    public func changeColor(to color: UIColor) {
        self.currentColor = color;
    }
    
    public func optionTapped(sender: UIButton) {
        setCurrentColor(optionButton: sender)
    }
    
    private func makeColorOption(frame: CGRect, color: UIColor) -> UIButton {
        let optionButton = UIButton(frame: frame);
        
        optionButton.layer.cornerRadius = optionButton.frame.width/2
        
        let colorValues = CoreImage.CIColor(color: color)
        
        if colorValues.green > 0.85 && colorValues.red > 0.85 && colorValues.blue > 0.85 {
            addBorder(to: optionButton as UIView, on: .all, ofWidth: 0.3, andColor: UIColor.black)

        }
        
        optionButton.backgroundColor = color;
        
        return optionButton;
    }
    
    private func selectButton(button: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            
            self.currentColorIndicator!.center = button.center
            
        }, completion: nil)
    }
    
    
    class CurrentColorIndicator: UIView {
        
        var borderColor = UIColor.black.cgColor
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.layer.cornerRadius = self.frame.width/2
            
            self.layer.borderWidth = 3;
            self.layer.cornerRadius = self.frame.width / 2
            self.layer.borderColor = borderColor;
            
            
            self.layer.masksToBounds = false;
            
            self.layer.zPosition = -10
            self.isUserInteractionEnabled = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
}
