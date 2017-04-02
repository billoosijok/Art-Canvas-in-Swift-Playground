import UIKit


public class DrawingCanvasView: UIView {
    
    // MARK: Properties
    public var activeDrawing : Drawing?
    private var lastActiveDrawing : Drawing?
    var drawings = [Drawing]()
    var colorPickerView: ColorPickerView?
    var currentColor: UIColor? {
        return colorPickerView!.currentColor
    }
    var deleteArea = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
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
    public var drawingDidDelete = {}
    
    public init(frame: CGRect, shapes: [Shape], colorPicker: ColorPickerView) {
        super.init(frame: frame)
        
        setupSceneElements()
        sceneGestures()
        
        self.shapes = shapes
        self.currentShape = shapes[0]
        self.colorPickerView = colorPicker
        
        self.clipsToBounds = true
    
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Functions
    
    /**
     Simply sets up any subviews
     */
    private func setupSceneElements() {
        layoutIfNeeded()
        
        // This is the delete area button
        self.deleteArea.frame.origin.y = -self.deleteArea.frame.height
        self.deleteArea.frame.origin.x = 5
        self.deleteArea.layer.cornerRadius = self.deleteArea.frame.width / 2
        self.deleteArea.image = UIImage(named: "trash")
        self.deleteArea.contentMode = .scaleAspectFit
        self.deleteArea.layer.zPosition = 10
        self.deleteArea.backgroundColor = UIColor.white
        self.addSubview(deleteArea)
    }
    
    /**
     Attaches gestures to all the DrawingCanvasView
     */
    private func sceneGestures() {
        
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
    /**
     Creates a new Drawing instance at the given position.
     
     - parameter position: The point in which the Drawing should be started.
     */
    func createNewDrawing(at position: CGPoint) {
        
        // Creating the new Drawing
        let newDrawing = Drawing(withShape: currentShape!, withInitialColor: self.currentColor!, andShapeRadius: self.shapeRadius, andShapeMargin: self.shapeMargin)
        
        // Setting the new Drawing to be active
        activeDrawing = newDrawing
        
        // Adding the Drawing to the history array
        self.addDrawingToHistory(drawing: self.activeDrawing!)
        
        // Scaling it to 0 so it can be animated in.
        newDrawing.center = position
        newDrawing.positionBeforeDeletion = position
        newDrawing.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        // Adding gestures to the Drawing.
        // - LongPress : allows the Drawing to be placed somewhere else.
        // - Tap : makes a drawing active
        newDrawing.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed)))
        newDrawing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.drawingTapped)))
        
        self.addSubview(newDrawing)
        
        // Animating the Drawing in by scaling it all the way up.
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
            
            newDrawing.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        })
        
        // Finally calling the onNewDrawingCreated event
        self.onNewDrawingCreated()
        
    }
    
    /**
     Sets the given drawing to be the active drawing
     */
    func setActiveDrawing(drawing: Drawing) {
        if self.activeDrawing != nil {
            self.lastActiveDrawing = activeDrawing
        }
        self.activeDrawing = drawing
    }
    
    /**
     Undoes the last move.
     */
    public func undo() {
        if self.history.count > 0 {
            let prevDrawing = history.popLast()!
            
            // The last drawing is deleted, then undo() should put it back where it was
            if prevDrawing.isDeleted {
                // Readding it to the view
                self.addSubview(prevDrawing)
                prevDrawing.center = prevDrawing.positionBeforeDeletion
                UIView.animate(withDuration: 0.3, animations: {
                    prevDrawing.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(_: Bool) in
                    prevDrawing.isDeleted = false
                    
                })
            } else {
                prevDrawing.undo()
            }
        }
    }
    
    /**
     Adds the drawing passed to history.
     */
    func addDrawingToHistory(drawing: Drawing) {
        
        // If history is more than 200 then we start
        // ommiting the really old ones.
        if history.count > 200 {
            history.removeFirst()
        }
        history.append(drawing)
    }

    // MARK: Gestures Responders
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
            // Adding the active drawing to the array so that it can be retrieved to
            // call its undo()
            self.addDrawingToHistory(drawing: self.activeDrawing!)
            
            // This is to be overridden with custom functionalities
            didPopulateAShape()
        }
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let touchPosition = sender.location(in: self)
        createNewDrawing(at: touchPosition)
        
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        let touchPosition = sender.location(in: self)
        
        switch sender.state {
        case .began:
            
           if (sender.view as? Drawing) != nil && !(sender.view as? Drawing)!.isDeleted {
            
                setActiveDrawing(drawing: sender.view as! Drawing)
                shapeEditingDidBegin()

                // Showing the delete area
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.frame.origin.y += self.deleteArea.frame.height + 10
                })
            
                // This is the difference between the touch position and the origin of 
                // the shape, so when the origin gets moved the difference is added in.
                diffX = sender.location(in: self).x - self.activeDrawing!.center.x
                diffY = sender.location(in: self).y - self.activeDrawing!.center.y
            
                // Popping out the Drawing to visually show that its movable
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    self.activeDrawing!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.activeDrawing!.center.x = sender.location(in: self).x - self.diffX - 5
                    self.activeDrawing!.center.y = sender.location(in: self).y - self.diffY - 5
                    
                }, completion: { (_: Bool) in
                
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        
                        self.activeDrawing!.transform = CGAffineTransform(scaleX: 1, y: 1)
                        
                    })
                })
            }
    
        case .changed:
            
            // Moving the Drawing to the position of the touch and adding the diffX/diffY
            activeDrawing!.center.x = sender.location(in: self).x - self.diffX - 5
            activeDrawing!.center.y = sender.location(in: self).y - self.diffY - 5
            
            // If the touch was inside the trash area, it's colored in red
            // or else it goes back to white.
            if pointIsWithin(point: touchPosition, rect: self.deleteArea.frame) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.backgroundColor = rgb(255, 100, 100)
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.deleteArea.backgroundColor = UIColor.white
                })
            }
            
        case .ended:
            if (sender.view as? Drawing) != nil {
                
                // If the dragging ended inside the trash can icon then we delete the 
                // drawing.
                if pointIsWithin(point: touchPosition, rect: self.deleteArea.frame) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activeDrawing?.center = self.deleteArea.center
                    })
                    
                    // Adding the drawing to history to redraw it on 'undo'
                    self.addDrawingToHistory(drawing: self.activeDrawing!)
                    self.activeDrawing?.delete()
                    self.setActiveDrawing(drawing: self.lastActiveDrawing!)
                    
                    self.drawingDidDelete()
                    
                } else {
                    // Because it wasn't deleted we update this flag for the next time around. 
                    // if it gets deleted we use this point to recreate the drawing when the 
                    // user taps 'undo'
                    self.activeDrawing?.positionBeforeDeletion = self.activeDrawing!.center
                }
                
                // Hiding the trash icon
                UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                    self.deleteArea.frame.origin.y -= self.deleteArea.frame.height + 10
                })
                
                // Running the event
                shapeEditingDidEnd()
            }
            
        default:
            break
        }
    }
    
    /**
     It basically makes a drawing active when it's tapped
     */
    func drawingTapped(sender: UITapGestureRecognizer) {
        
        if let tappedDrawing = sender.view as? Drawing? {
            setActiveDrawing(drawing: tappedDrawing!)
            
            // Hilighting all the shapes to show that they are active
            for shape in tappedDrawing!.shapesDrawn {
                UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .autoreverse, animations: {
                    shape.backgroundColor = rgb(203, 216, 237)
                }, completion: {(_ : Bool) in
                    shape.backgroundColor = UIColor.clear
                })
            }
        }
    }
}

/**
 A drawing is a single part of the DrawingCanvasView that can be composed of multiple Shapes. The DrawingCanvasView class creates a new drawing whenever the user double taps.
 
 */
public class Drawing: UIView {
    
    // MARK: Properties
    public var shapeRadius : CGFloat = 5
    public var shapeMargin : CGFloat?
    
    var currentTip: Shape? // basically the current shape which was last drawn.
    var shapesDrawn = [Shape]()
    
    public var currentShape : Shape?
    public var currentColor: UIColor?
    
    public var isDeleted = false
    public var positionBeforeDeletion = CGPoint()

    
    // MARK: Inits
    public init(withShape shape: Shape, withInitialColor color: UIColor,andShapeRadius radius: CGFloat, andShapeMargin margin: CGFloat) {
        
        // Setting up properties
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.currentShape = shape
        self.currentColor = color
        self.shapeMargin = margin
        self.shapeRadius = radius
        
        super.init(frame: frame)
        
        // Setting up the first shape
        self.currentShape = Shape(usingView: shape.shapeView!, ofSize: CGSize(width: shapeRadius*2, height:shapeRadius*2), andMargin: shapeMargin!, andColor: currentColor!)
        self.currentShape!.center = self.center
        addShape(shape: self.currentShape!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Functions
    
    /**
     Creates a duplicate of the Current Shape towards a certain side in the screen (passed as a parameter).
     
     - parameter direction: The direction in which the shape should be drawin.
     - parameter color: The color of the new shape.
     
     - returns: The populated `Shape` object.
     */
    public func populate( towards direction: Side, withColor color: UIColor) -> Shape {
        
        let newShape = makeAnotherShape(like: self.currentShape!, withColor: self.currentTip!.shapeView!.backgroundColor!)
        addShape(shape: newShape)
        
        // This is the destination of the newly created shape
        // This will be different depending on the direction of the swipe
        var destinationCenterValue: CGFloat;
        
        switch direction {
        case .right:
            destinationCenterValue = (newShape.frame.origin.x) + (newShape.frame.width) + (newShape.frame.width/2)
            
        case .left:
            destinationCenterValue = (newShape.frame.origin.x) - (newShape.frame.width) + (newShape.frame.width/2)
            
        case .bottom:
            destinationCenterValue = (newShape.frame.origin.y) + (newShape.frame.height) + (newShape.frame.height/2)
            
        case .top:
            destinationCenterValue = (newShape.frame.origin.y) - (newShape.frame.height) + (newShape.frame.height/2)
            
        default:
            fatalError("Direction can only be .top, .right, .bottom, .left")
            
        }
        
        newShape.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            if direction == .right || direction == .left {
                newShape.center.x = destinationCenterValue
            } else {
                newShape.center.y = destinationCenterValue
            }
            
            newShape.shapeView!.backgroundColor = color
            newShape.transform = CGAffineTransform(scaleX: 1, y: 1)
            
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
            let prevTip = shapesDrawn[shapesDrawn.count - 2]
            
            UIView.animate(withDuration: 0.2, animations: {
                
                // To give an epic reverse effect 👍
                self.currentTip!.center = prevTip.center
                self.currentTip!.shapeView!.backgroundColor = prevTip.shapeView!.backgroundColor
                
            }, completion: {(_ : Bool) in
                
                // Pop the shape out of the array and out of its super view
                self.shapesDrawn.popLast()?.removeFromSuperview()
                
            })
            
            // Now the previous one becomes the current .. 🎉
            self.currentTip = prevTip
            
        } else {
            /* This is when we're undoing the very last shape */
            self.delete()
            
        }
    }
    
    public func delete() {
        
        // Basically it grows bigger, then shrinks and disappears
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }, completion: {(done: Bool) in
            
            if(done) {
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    // For some reason animation doesn't work when animating to scale of 0
                    self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                }, completion: { (done: Bool) in
                    
                    self.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.isDeleted = true
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


/**
 The Shape class creates a UIVIew container that contains the shape instance passed as UIView.
 It includes the following convenient initializers:
 
 - `init(circleWithSize size: CGSize, margin: CGFloat, color: UIColor)`:
    It helps you to quickly create a circle shape without passing the view paramenter
 
 - `init(ofType type: shapeTypes, size: CGSize, margin: CGFloat, color: UIColor)`:
    It can help you create a shape by just passing the shape type
*/
public class Shape: UIView {
    
    // MARK: Properties
    public var margin : CGFloat?
    public var shapeView : UIView?
    public var size: CGSize?
    public var color: UIColor?
    
    /**
     Available shapes are: `.circle`, `.square`
    */
    public enum shapeTypes {
        case circle, square
    }
    
    // MARK: Inits
    public init(usingView view: UIView, ofSize size: CGSize, andMargin margin: CGFloat, andColor color: UIColor) {
        
        // Setting up properties
        self.shapeView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        self.margin = margin
        self.color = color
        self.size = size
        
        // We use the shape's dimentions to create a container for the shape as the 'self'
        // then we add the shape to the container
        super.init(frame: CGRect(x: 0, y: 0, width: self.size!.width + margin*2, height: self.size!.height + margin*2))
        
        let cornerAspect = view.frame.width / view.layer.cornerRadius
        // Just in case the shape has rounded corners
        self.shapeView!.layer.cornerRadius = self.shapeView!.frame.width / cornerAspect
        
        self.createShape()
        
    }
    
    public convenience init(circleWithSize size: CGSize, margin: CGFloat, color: UIColor) {
        /* Creates a circle shape for convenience */
        
        let view = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size));
        
        self.init(usingView: view, ofSize: size, andMargin: margin, andColor: color)
        
        self.shapeView!.layer.cornerRadius = shapeView!.frame.width/2
        
        self.createShape()
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
    
    // MARK: functions
    
    /**
     Sets up the actual shape and adds to its container.
     */
    private func createShape() {
        
        self.shapeView?.center = self.center
        
        // This is where the shape gets its color
        shapeView!.backgroundColor = self.color!;
        
        self.addSubview(shapeView!)
        
    }
    
}

