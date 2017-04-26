import UIKit

public class ColorPickerView: UIScrollView {
    
    // MARK: Properties
    public var colors = [UIColor]()
    public var optionButtons = [UIButton]()
    public var currentColor = UIColor.red
    
    private var colorIndicator : ColorIndicator?
    private var optionSize = CGSize()
    
    // MARK: Init
    public init(frame: CGRect, withColors colors: [UIColor]) {
        super.init(frame: frame)
        
        // Seting up the container of the color pallet and the color options
        self.colors = colors
        self.isScrollEnabled = true
        
        let optionSize = CGSize(width: self.frame.height/2, height: self.frame.height/2)
        let spacingFactor = max(50, self.frame.width / CGFloat(colors.count))
        
        // Creating the color buttons
        // and adding them to the view and the array
        for i in 0..<colors.count {
            
            let optionFrame = CGRect(origin: CGPoint(x: CGFloat(i) * spacingFactor + (optionSize.width/2), y: self.frame.height/2 - optionSize.height/2), size: optionSize)
            let option = makeColorOption(frame: optionFrame, color: colors[i]);
            
            option.addTarget(self, action: #selector(self.optionTapped), for: .touchUpInside)
            
            optionButtons.append(option)
            
            self.addSubview(option);
        }
        
        // Setting the content size to fit all the options ..
        // Also adding 30 as a spacer
        self.contentSize.width = optionButtons.last!.frame.origin.x + optionSize.width + 30
        
        // This will be used to indicate the current
        colorIndicator = ColorIndicator(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: optionSize.width + 10, height: optionSize.height + 10)))
        self.addSubview(colorIndicator!)
        
        // Finally setting the first color to be the current on
        // using the first option button in the array
        updateCurrentColor(optionButton: optionButtons.first!)
    }
    
    convenience override public init(frame: CGRect) {
        /* This creates a default color pallet if only the frame is provided */
        
        let colors = [
            rgb(255,182,30),  rgb(108,122,137),
            rgb(217,182,17),  rgb(77,175,124),
            rgb(249,105,14),  rgb(38,67,72),
            rgb(13, 65, 94),  rgb(198,116,91),
            rgb(0, 118,127),  rgb(0,84,127)
        ];
        
        self.init(frame: frame, withColors: colors)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Functions
    public func updateCurrentColor(optionButton: UIButton) {
        /* Takes care of changing the color and updating the color indicator */
        
        changeColor(to: optionButton.backgroundColor!)
        selectButton(button: optionButton)
    }
    
    public func changeColor(to color: UIColor) {
        /* Sets the current color using the color passed */
        
        self.currentColor = color;
    }
    
    public func optionTapped(sender: UIButton) {
        /* This is the action attached to the color buttons */
        
        updateCurrentColor(optionButton: sender)
    }
    
    private func makeColorOption(frame: CGRect, color: UIColor) -> UIButton {
        /* A a factory function that creates an option button */
        
        // Making the button and setting it up
        let optionButton = UIButton(frame: frame);
        
        optionButton.layer.cornerRadius = optionButton.frame.width/2
        optionButton.backgroundColor = color;
        
        // This is done to make sure that if the color is close to white (the
        // background color) a border is added
        let colorValues = CoreImage.CIColor(color: color)
        if colorValues.green > 0.85 && colorValues.red > 0.85 && colorValues.blue > 0.85 {
            addBorder(to: optionButton as UIView, on: .all, ofWidth: 0.3, andColor: UIColor.black)
        }
        
        return optionButton;
    }
    
    private func selectButton(button: UIButton) {
        /* Animates the color indicator to the clicked color */
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.colorIndicator!.center = button.center
        })
    }
    
    // MARK: Private Class
    class ColorIndicator: UIView {
        /* This class creates a UIView that is then used by the color picker
         to circle the current color
         */
        
        var borderColor = UIColor.black.cgColor
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.layer.cornerRadius = self.frame.width/2
            self.layer.borderWidth = 2.5;
            self.layer.borderColor = borderColor;
            
            // This is so that the buttons underneth can recieve the touch
            self.isUserInteractionEnabled = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}
