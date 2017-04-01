import UIKit


public class DrawingCanvasView: UIScrollView {
    
    // MARK: Properties
    public var activeDrawing : Drawing?
    var drawings = [Drawing]()
    var colorPickerView: ColorPickerView?
    var currentColor: UIColor? {
        return colorPickerView!.currentColor
    }
    var deleteArea = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    var gridSpacing : CGFloat = 3
    
    public var shapes = [Shape]()
    public var shapeMargin : CGFloat = 0
    public var shapeRadius : CGFloat = 5
    public var currentShape: Shape?
    
    private var diffX : CGFloat = 0
    private var diffY : CGFloat = 0

    public var history = [Drawing]()
    
    public var onNewDrawingCreated = {}
    public var didPopulateAShape = {}
    public var shapeEditingDidBegin = {}
    public var shapeEditingDidEnd = {}
    
    public init(frame: CGRect, shapes: [Shape], colorPicker: ColorPickerView) {
        super.init(frame: frame)
        
        setupSceneElements()
        sceneGestures()
        
        self.shapes = shapes
        self.currentShape = shapes[0]
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
    
    private func setupSceneElements() {
        layoutIfNeeded()
        
        self.deleteArea.frame.origin.y = -self.deleteArea.frame.height
        self.deleteArea.frame.origin.x = 5
        self.deleteArea.layer.cornerRadius = self.deleteArea.frame.width / 2
        self.deleteArea.image = UIImage(named: "trash")
        self.deleteArea.contentMode = .scaleAspectFit
        self.addSubview(deleteArea)
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
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped(sender:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
    }
    
    func swiped(sender: UISwipeGestureRecognizer) {
        let direction = sender.direction;
        
        switch direction {
            
        case UISwipeGestureRecognizerDirection.right:
            let _ = activeDrawing?.populate( towards: .right, withColor: currentColor!)
            
        case UISwipeGestureRecognizerDirection.left:
            let _ = activeDrawing?.populate( towards: .left, withColor: currentColor!)
            
        case UISwipeGestureRecognizerDirection.up:
            let _ = activeDrawing?.populate( towards: .top, withColor: currentColor!)
            
        case UISwipeGestureRecognizerDirection.down:
            let _ = activeDrawing?.populate( towards: .bottom, withColor: currentColor!)

        default:
            break;
        }
        if self.activeDrawing != nil {
            history.append(self.activeDrawing!)
            
            // This is to be overridden with custom functionalities
            didPopulateAShape()
        }
        
        
        
    }
    
    
    func createNewDrawing(at position: CGPoint) {
        let newDrawing = Drawing(withShape: currentShape!, withInitialColor: self.currentColor!, andShapeRadius: self.shapeRadius, andShapeMargin: self.shapeMargin)
        
        activeDrawing = newDrawing
        history.append(self.activeDrawing!)
        
        newDrawing.center = position
        newDrawing.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        newDrawing.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed)))
        newDrawing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.drawingTapped)))
        
        self.addSubview(newDrawing)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
        
            newDrawing.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }, completion: {(_: Bool) in
        
            self.onNewDrawingCreated()
        })
        
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let touchPosition = sender.location(in: self)
        createNewDrawing(at: touchPosition)
        
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        let touchPosition = sender.location(in: self)
        
        switch sender.state {
        case .began:
            
            
            
           if (sender.view as? Drawing) != nil {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.frame.origin.y += self.deleteArea.frame.height + 10
                })
                
                setActiveDrawing(drawing: sender.view as! Drawing)
                shapeEditingDidBegin()
            
            
                diffX = sender.location(in: self).x - self.activeDrawing!.center.x
                diffY = sender.location(in: self).y - self.activeDrawing!.center.y
                gridSpacing = activeDrawing!.shapeRadius * 2 + activeDrawing!.shapeMargin!

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    self.activeDrawing!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.activeDrawing!.center.x = round((sender.location(in: self).x - self.diffX - 5) / self.gridSpacing) * self.gridSpacing
                    self.activeDrawing!.center.y = round((sender.location(in: self).y - self.diffY - 5) / self.gridSpacing) * self.gridSpacing
                    
                }, completion: { (_: Bool) in
                
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        
                        self.activeDrawing!.transform = CGAffineTransform(scaleX: 1, y: 1)
                        
                    }, completion: nil)
                })
            }
    
        case .changed:
            
            activeDrawing!.center.x = sender.location(in: self).x - self.diffX - 5
            activeDrawing!.center.y = sender.location(in: self).y - self.diffY - 5
            
            if pointIsWithin(point: touchPosition, rect: self.deleteArea.frame) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.backgroundColor = rgba(255, 0, 0, 0.5)
                    self.deleteArea.tintColor = UIColor.white
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.backgroundColor = UIColor.clear
                    self.deleteArea.tintColor = UIColor.clear
                })
            }
            
        case .ended:
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                
                self.activeDrawing!.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            }, completion: nil)
            
            
            if (sender.view as? Drawing) != nil {
                shapeEditingDidEnd()
                
                if pointIsWithin(point: touchPosition, rect: self.deleteArea.frame) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activeDrawing?.center = self.deleteArea.center
                    })
                    
                    self.activeDrawing?.delete()
                }
                
                UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                    self.deleteArea.frame.origin.y -= self.deleteArea.frame.height + 10
                })
                
                
            }

            
            
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
    
    func pointIsWithin(point: CGPoint, rect: CGRect) -> Bool {
        
        let rectXExtention = rect.origin.x + rect.width
        let rectYExtention = rect.origin.y + rect.height
        
        if (point.x < rectXExtention
            && point.x > rect.origin.x)
            
            || (point.y < rectYExtention
                && point.y > rect.origin.y) {
        
            return true
        }
        
        
        return false
    }
    
    public func undo() {
        if self.history.count > 0 {
            history.popLast()?.undo()
        }
    }
    
}

public class Drawing: UIView {
    
    // MARK: Properties
    public var currentShape : Shape?
    public var currentColor: UIColor?
    
    var currentTip: Shape?
    var shapesDrawn = [Shape]()
    var prevShape : Shape?
    
    public var shapeRadius : CGFloat = 5
    public var shapeMargin : CGFloat?
    
    // MARK: Init
    public init(withShape shape: Shape, withInitialColor color: UIColor,andShapeRadius radius: CGFloat, andShapeMargin margin: CGFloat) {
        
        // Setting up properties
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.currentShape = shape
        self.currentColor = color
        self.shapeMargin = margin
        self.shapeRadius = radius
        
        super.init(frame: frame)
        
        // Setting up the first circle
        self.currentShape = Shape(usingView: shape.shapeView!, ofSize: CGSize(width: shapeRadius*2, height:shapeRadius*2), andMargin: shapeMargin!, andColor: currentColor!)
        self.currentShape!.center = self.center
        
        // Initial Circle
        addShape(shape: self.currentShape!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Functions
    public func populate( towards direction: Side, withColor color: UIColor) -> Shape {
        
        let newShape = makeAnotherShape(like: self.currentShape!, withColor: self.currentTip!.shapeView!.backgroundColor!)
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
        
//        newShape.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            if direction == .right || direction == .left {
                newShape.frame.origin.x = destinationValue
                
            } else { newShape.frame.origin.y = destinationValue }
            
            newShape.shapeView!.backgroundColor = color
//            newShape.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        })
        
        return newShape
    }

    private func makeAnotherShape(like originalShape: Shape, withColor color: UIColor) -> Shape {
        
        let newShapeSize = CGSize(width: self.shapeRadius * 2, height: self.shapeRadius * 2)
        let newShape = Shape(usingView: originalShape.shapeView!, ofSize: newShapeSize, andMargin: self.shapeMargin!, andColor: color)
        
        newShape.center = currentTip!.center
        
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
            self.delete()
            
        }
        
    }
    
    func delete() {
        
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
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // This is overridden because the Shapes(the subviews) are outside the bounds of the view
        // source: Noam -
        // http://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest

        for subview in self.subviews {
            let subPoint = (subview as? Shape)?.shapeView?.convert(point, from: self)
            let result = (subview as? Shape)?.shapeView?.hitTest(subPoint!, with:event);
            
            if (result != nil) {
                return result;
            }
        }
        
        return nil
    }
}


public class Shape: UIView {
    
    public var margin : CGFloat?
    public var shapeView : UIView?
    public var size: CGSize?
    public var color: UIColor?
    
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
        
        let cornerAspect = view.frame.width / view.layer.cornerRadius
        // Just in case the shape has rounded corners
        self.shapeView!.layer.cornerRadius = self.shapeView!.frame.width / cornerAspect
        
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

