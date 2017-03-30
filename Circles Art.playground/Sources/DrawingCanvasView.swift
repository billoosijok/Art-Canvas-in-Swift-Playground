import UIKit


public class DrawingCanvasView: UIScrollView {
    
    // MARK: Properties
    public var activeDrawing : Drawing?
    var drawings = [Drawing]()
    var colorPickerView: colorPickerView?
    var currentColor: UIColor? {
        return colorPickerView!.currentColor
    }
    
    var gridSpacing : CGFloat = 3
    
    public var shapeMargin : CGFloat = 0
    public var shapeRadius : CGFloat = 5
    public var currentShape: Shape?
    
    private var diffX : CGFloat = 0
    private var diffY : CGFloat = 0

    
    public init(frame: CGRect, shapes: [Shape], colorPicker: colorPickerView) {
        super.init(frame: frame)
        
        sceneGestures()
        
        self.colorPickerView = colorPicker
        self.clipsToBounds = true
        self.isScrollEnabled = true
        self.bounces = true
        self.contentSize.width = self.frame.width
        self.contentSize.height = self.frame.height
    

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func sceneGestures() {
        
        for gesture in self.gestureRecognizers! {
            if gesture is UIPanGestureRecognizer {
                (gesture as! UIPanGestureRecognizer).minimumNumberOfTouches = 2
            }
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeRight.direction = .right;
        self.addGestureRecognizer(swipeRight);
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeDown.direction = .down;
        self.addGestureRecognizer(swipeDown);
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeUp.direction = .up;
        self.addGestureRecognizer(swipeUp);
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
        swipeLeft.direction = .left;
        self.addGestureRecognizer(swipeLeft);
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed))
        self.addGestureRecognizer(longPress);
        
    }
    
    func swiped(sender: UISwipeGestureRecognizer) {
        let direction = sender.direction;
        
        switch direction {
            
        case UISwipeGestureRecognizerDirection.right:
            let _ = activeDrawing?.populate( towards: .right, withColor: currentColor!)
            self.updateContentSize()
            
        case UISwipeGestureRecognizerDirection.left:
            let _ = activeDrawing?.populate( towards: .left, withColor: currentColor!)
            self.updateContentSize()
            
        case UISwipeGestureRecognizerDirection.up:
            let _ = activeDrawing?.populate( towards: .top, withColor: currentColor!)
            self.updateContentSize()
            
        case UISwipeGestureRecognizerDirection.down:
            let _ = activeDrawing?.populate( towards: .bottom, withColor: currentColor!)
            self.updateContentSize()
            
        default:
            break;
        }
    }
    
    
    func createNewDrawing(at position: CGPoint) {
        let newDrawing = Drawing(withInitialColor: self.currentColor!, andShapeRadius: self.shapeRadius, andShapeMargin: self.shapeMargin)
        
        activeDrawing = newDrawing
        
        newDrawing.center = position
        newDrawing.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        newDrawing.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed)))
        newDrawing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.drawingTapped)))
        
        self.addSubview(newDrawing)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
        
            newDrawing.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }, completion: nil)
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            
            let touchPosition = sender.location(in: self)
            
            if (sender.view as? DrawingCanvasView) != nil {
                createNewDrawing(at: touchPosition)
            } else if (sender.view as? Drawing) != nil {
                setActiveDrawing(drawing: sender.view as! Drawing)
            }
            
            diffX = sender.location(in: self).x - self.activeDrawing!.center.x
            diffY = sender.location(in: self).y - self.activeDrawing!.center.y
            gridSpacing = activeDrawing!.shapeRadius * 2 + activeDrawing!.margin!

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.activeDrawing!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.activeDrawing!.center.x = round((sender.location(in: self).x - self.diffX - 5) / self.gridSpacing) * self.gridSpacing
                self.activeDrawing!.center.y = round((sender.location(in: self).y - self.diffY - 5) / self.gridSpacing) * self.gridSpacing
                
            }, completion: { (_: Bool) in
            
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.activeDrawing!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    
                }, completion: nil)
            })
    
        case .changed:
            
            activeDrawing!.center.x = sender.location(in: self).x - self.diffX - 5
            activeDrawing!.center.y = sender.location(in: self).y - self.diffY - 5

        case .ended:
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                
                self.activeDrawing!.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            }, completion: nil)
            self.updateContentSize()
            
        default:
            break
        }
    }
    
    func setActiveDrawing(drawing: Drawing) {
        self.activeDrawing = drawing
    }
    
    func drawingTapped(sender: UITapGestureRecognizer) {
        
        let tappedDrawing = sender.view! as! Drawing
        
        setActiveDrawing(drawing: tappedDrawing)
        
        for shape in tappedDrawing.shapesDrawn {
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .autoreverse, animations: {
                shape.backgroundColor = rgb(203, 216, 237)
            }, completion: {(_ : Bool) in
                
                shape.backgroundColor = UIColor.clear
                
            })
        }
        
    }
    
    internal func updateContentSize() {
        
        
//        let shapes = self.activeDrawing?.subviews;
//        let scrollViewMargin : CGFloat = 80
//        
//        for shape in shapes! {
//            
//            let shapeInScrollView = self.activeDrawing!.convert(shape.frame, to: self);
//            
//            let shapeYExtention = shapeInScrollView.origin.y + shape.frame.height;
//            let shapeXExtention = shapeInScrollView.origin.x + shape.frame.width;
//            
//
//            if shapeXExtention > self.contentSize.width {
//                
//                self.contentSize.width = shapeXExtention + scrollViewMargin
//                self.setContentOffset(CGPoint(x: self.contentSize.width - self.bounds.width, y:self.contentOffset.y), animated: true)
//                
//            }
//            
//            if shapeYExtention > self.contentSize.height {
//                
//                self.contentSize.height = shapeYExtention + scrollViewMargin
//                self.setContentOffset(CGPoint(x: self.contentOffset.x, y: self.contentSize.height - self.bounds.height), animated: true)
//                
//            }
//            
//            self.flashScrollIndicators()
//        }
        
    }
    
}


public class Drawing: UIView {
    
    // MARK: Properties
    var shape : Shape?
    var currentColor: UIColor?
    
    var currentTip: Shape?
    var shapesDrawn = [Shape]()
    var prevShape : Shape?
    
    public var shapeRadius : CGFloat = 5
    public var margin : CGFloat?
    
    // MARK: Init
    public init(withInitialColor color: UIColor,andShapeRadius radius: CGFloat, andShapeMargin margin: CGFloat) {
        
        // Setting up properties
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.currentColor = color
        self.margin = margin
        self.shapeRadius = radius
        
        super.init(frame: frame)
        
        // Setting up the first circle
        self.shape =  Shape(ofType: .square, size: CGSize(width: shapeRadius * 2, height: shapeRadius * 2), margin: self.margin!, color: self.currentColor!)
        self.shape!.center = self.center
        
        // Initial Circle
        addShape(shape: self.shape!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Functions
    public func populate( towards direction: Side, withColor color: UIColor) -> Shape {
        
        let newShape = makeAnotherShape(like: self.currentTip!)
        addShape(shape: newShape)
        
        // This will be different depending on the direction of the swipe
        var destinationValue: CGFloat;
        
        switch direction {
        case .right:
            destinationValue = newShape.frame.origin.x + (newShape.frame.width)
            
        case .left:
            destinationValue = newShape.frame.origin.x - (newShape.frame.width)
            
        case .bottom:
            destinationValue = newShape.frame.origin.y + (newShape.frame.height)
            
        case .top:
            destinationValue = newShape.frame.origin.y - (newShape.frame.height)
            
        default:
            fatalError("Direction can only be .top, .right, .bottom, .left")
            
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            
            if direction == .right || direction == .left {
                newShape.frame.origin.x = destinationValue
                
            } else { newShape.frame.origin.y = destinationValue }
            
            newShape.shapeView!.backgroundColor = color
            
        })
        
        
        
        return newShape
    }

    private func makeAnotherShape(like originalShape: Shape) -> Shape {
        
        let newShapeSize = CGSize(width: self.shapeRadius * 2, height: self.shapeRadius * 2)
        let newShape = Shape(usingView: originalShape.shapeView!, ofSize: newShapeSize, andMargin: self.margin!, andColor: originalShape.shapeView!.backgroundColor!)
        
        newShape.frame.origin = originalShape.frame.origin
        
        
        
        return newShape
    }
    
    private func addShape(shape: Shape) {
        /* Adds the shape to the view and array */
        self.addSubview(shape)
        
        // and making it the current, since it's the newest
        self.currentTip = shape
        
        shapesDrawn.append(self.currentTip!)
    }
    
    public func undo() {
        
        // Because if there is only one then we nuke the entire drawing (in 'else')
        if shapesDrawn.count > 1 {
            
            // We use it to animate the current shape towards the previous one
            let prevShape = shapesDrawn[shapesDrawn.count - 2]
            
            UIView.animate(withDuration: 0.2, animations: {
                
                // To give an epic reverse effect 👍
                self.currentTip!.center = prevShape.center
                self.currentTip!.shapeView!.backgroundColor = prevShape.shapeView!.backgroundColor
                
            }, completion: {(_ : Bool) in
                
                // Pop the shape out of the array and out of its super view
                self.shapesDrawn.popLast()?.removeFromSuperview()
                
            })
            
            // Now the previous one becomes the current .. 🎉
            self.currentTip = prevShape
            
        } else {
            /* This is when we're undoing the very last shape */
            
            // Basically it grows bigger, then shrinks and disappears
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
            }, completion: {(done: Bool) in
    
                if(done) {
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        
                        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        
                    }, completion: { (done: Bool) in
    
                        self.removeFromSuperview()
                        
                    })
                }
            })
        }
        
        (self.superview as! DrawingCanvasView).updateContentSize()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // This is overridden because the Shapes(the subviews) are outside the bounds of the view
        // source: Noam -
        // http://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest

        for subview in self.subviews {
            let subPoint = subview.convert(point, from: self)
            let result = subview.hitTest(subPoint, with:event);
            
            if (result != nil) {
                return result;
            }
        }
        
        return nil
    }
}


public class Shape: UIView {
    
    var margin : CGFloat?
    var shapeView : UIView?
    var size: CGSize?
    var color: UIColor?
    
    public enum shapeTypes {
        case circle, square
    }
    
    public init(usingView view: UIView, ofSize size: CGSize, andMargin margin: CGFloat, andColor color: UIColor) {
        
        // Regular init
        self.shapeView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        self.margin = margin
        self.color = color
        self.size = size
        
        super.init(frame: CGRect(x: 0, y: 0, width: self.size!.width + margin*2, height: self.size!.height + margin*2))
        
        // Just in case the shape has rounded corners
        self.shapeView!.layer.cornerRadius = view.layer.cornerRadius
        
        createShape()
        
    }
    
    public convenience init(circleWithSize size: CGSize, margin: CGFloat, color: UIColor) {
        /* Creates a circle shape for convenience */
        
        let view = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size));
        
        self.init(usingView: view, ofSize: size, andMargin: margin, andColor: color)
        
        self.shapeView!.layer.cornerRadius = shapeView!.frame.width/2
        
        createShape()
    }
    
    public convenience init(ofType type: shapeTypes, size: CGSize, margin: CGFloat, color: UIColor) {
        /* Creates a shape based on Type */
        
        switch type {
        case .circle:
            self.init(circleWithSize: size, margin: margin, color: color)
        case .square:
            let view = UIView()
            self.init(usingView: view, ofSize: size, andMargin: margin, andColor: color)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createShape() {
        /* Sets up the actual shape and adds to its container */
        
        self.shapeView?.center = self.center
        
        // This is where the shape gets its color
        shapeView!.backgroundColor = self.color!;
        
        self.addSubview(shapeView!)
        
    }
    
}

