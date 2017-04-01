//#-hidden-code
//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

public class InteractiveCanvasView: UIViewController {
    
    // MARK: UI Elements
    public var toolBar: UIView?
    public var colorPicker: ColorPickerView?
    public var undoButton: UIButton?
    
    public var secondaryToolBar: UIView?
    public var shapeSelectMenu: DropDownMenu?
    public var shapeMarginSlider: UISlider?
    public var shapeRadiusSlider: UISlider?
    
    
    public var drawingCanvas: DrawingCanvasView?
    
    let undoImage : UIImage = #imageLiteral(resourceName: "undo@3x.png")
    
    // MARK: Properties
    public var colors = [UIColor]();
    public var shapeSpacing: CGFloat = 10
    public var backgroundColor = UIColor.white
    public var shapeRadius : CGFloat = 10
    
    public var shapes = [Shape]()
    public var shapeSelectorItems = [MenuItem]()
    
    private var popUp: Popup?
    
    private var createDrawingPopupDidShow = false
    private var swipePopupDidShow = false
    private var editShapePopupDidShow = false
    private var goodByePopupDidShow = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // DELETE
         view.frame.size = CGSize(width: 375, height: 650)
        
        let shape1 = Shape(ofType: .square, size: CGSize(width: 50, height: 50), margin: 2, color: UIColor.blue)
        let shape2 = Shape(ofType: .circle, size: CGSize(width: 50, height: 50), margin: 2, color: UIColor.blue)
        
        addShape(shape1)
        addShape(shape2)
        
        initUI()
        sceneSetup()
        addEventListeners()
        
        self.drawingCanvas?.shapeMargin = self.shapeSpacing
        self.drawingCanvas?.shapeRadius = self.shapeRadius;
        
    }
    
    private func initUI() {
        
        toolBar = UIView(frame : CGRect(x: 0, y: 0, width: view.frame.width, height: 70));
        
        undoButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: toolBar!.frame.height, height: toolBar!.frame.height)))
        
        if self.colors.count > 0 {
            colorPicker = ColorPickerView(frame : CGRect(x: undoButton!.frame.width + undoButton!.frame.origin.x, y: 0, width: view.frame.width - undoButton!.frame.width, height: 70), withColors: self.colors)
        } else {
            colorPicker = ColorPickerView(frame : CGRect(x: undoButton!.frame.width + undoButton!.frame.origin.x, y: 0, width: view.frame.width - undoButton!.frame.width, height: 70))
        }
        
        secondaryToolBar = UIView(frame : CGRect(x: 0, y: toolBar!.frame.origin.y + toolBar!.frame.height, width: view.frame.width, height: 40))
        
        shapeSelectMenu = DropDownMenu(atPosition: CGPoint(x: 0, y:0), withMenuItems: self.shapeSelectorItems)
        
        shapeMarginSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        
        shapeRadiusSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        
        drawingCanvas = DrawingCanvasView(frame: CGRect(x: 0, y: secondaryToolBar!.frame.origin.y + secondaryToolBar!.frame.height, width: view.frame.width, height:view.frame.height - secondaryToolBar!.frame.height - toolBar!.frame.height), shapes: self.shapes, colorPicker: colorPicker!)
        
        popUp = Popup(withText: "Welcome, Double Tap To Start", ofFontSize: 25)
    
    }
    
    private func sceneSetup() {
        
    // - ToolBar - \\
        view.addSubview(toolBar!)
        
        toolBar!.translatesAutoresizingMaskIntoConstraints = false
        toolBar!.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolBar!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolBar!.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        toolBar!.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addBorder(to: toolBar!, on: .bottom, ofWidth: 1, andColor: rgb(230,230,230))
        toolBar?.backgroundColor = rgb(250, 250, 250)
        
        
        // - Undo Button - \\
//        toolBar!.addSubview(undoButton!)
//        
//        undoButton!.translatesAutoresizingMaskIntoConstraints = false
//        undoButton!.leftAnchor.constraint(equalTo: toolBar!.leftAnchor).isActive = true
//        undoButton!.topAnchor.constraint(equalTo: toolBar!.topAnchor).isActive = true
//        undoButton!.heightAnchor.constraint(equalTo: (toolBar!.heightAnchor)).isActive = true
//        undoButton!.widthAnchor.constraint(equalToConstant: (toolBar!.frame.height)).isActive = true
        
        addBorder(to: undoButton as! UIView, on: .right, ofWidth: 0.5, andColor: rgb(230,230,230))

        
        undoButton?.setImage(undoImage, for: .normal)
        let imagePadding = undoButton!.frame.size.width / 4
        undoButton?.imageEdgeInsets =
            UIEdgeInsets(top: imagePadding, left: imagePadding,
                         bottom: imagePadding, right: imagePadding)
        undoButton?.imageView?.contentMode = .scaleAspectFit

        undoButton?.setTitleColor(rgb(0,0,155), for: .normal)
        undoButton?.setTitleColor(rgb(50,50,195), for: .highlighted)
        
        undoButton?.addTarget(self, action: #selector(self.undo), for: .touchUpInside)
        
        undoButton!.isEnabled = false
        
        // - Color Picker - \\
        toolBar!.addSubview(colorPicker!)
        
        colorPicker!.translatesAutoresizingMaskIntoConstraints = false
        colorPicker!.leftAnchor.constraint(equalTo: toolBar!.leftAnchor).isActive = true
        colorPicker!.topAnchor.constraint(equalTo: toolBar!.topAnchor).isActive = true
        colorPicker!.heightAnchor.constraint(equalTo: (toolBar!.heightAnchor)).isActive = true
        colorPicker!.rightAnchor.constraint(equalTo: (toolBar!.rightAnchor)).isActive = true
    
        
    // - Secondary Tool Bar \\
        view.addSubview(secondaryToolBar!)
        
        secondaryToolBar!.translatesAutoresizingMaskIntoConstraints = false
        secondaryToolBar!.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        secondaryToolBar!.topAnchor.constraint(equalTo: toolBar!.bottomAnchor).isActive = true
        secondaryToolBar!.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        secondaryToolBar!.heightAnchor.constraint(equalToConstant: 40).isActive = true

        secondaryToolBar!.clipsToBounds = false
        secondaryToolBar!.backgroundColor = UIColor.white
        
        // For subviews to use
        let placeInCenterOfSecondToolBar = {(view: UIView) in
            view.frame.origin.y = self.secondaryToolBar!.frame.height / 2 - view.frame.height/2
        }
    // - Margin Slider - \\
        let marginSliderLabel = makeHorizontalLabel(withText: "Spacing", xPosition: shapeSelectMenu!.frame.width+20, andWidth: 50)
        
        secondaryToolBar!.addSubview(marginSliderLabel)
        secondaryToolBar!.addSubview(shapeMarginSlider!)
        
        placeInCenterOfSecondToolBar(marginSliderLabel as! UIView)
        placeInCenterOfSecondToolBar(shapeMarginSlider as! UIView)
        
        shapeMarginSlider!.frame.origin.x = marginSliderLabel.frame.origin.x + marginSliderLabel.frame.width + 5
        
        makeSliderCool(slider: shapeMarginSlider!)
        
        shapeMarginSlider?.value = Float( shapeSpacing * 0.01 )
        
        shapeMarginSlider!.isContinuous = false
        shapeMarginSlider!.addTarget(self, action: #selector(self.marginUpdated), for: .valueChanged)
        
    // - Radius Slider - \\
        let radiusSliderLabel = makeHorizontalLabel(withText: "Size", xPosition: shapeMarginSlider!.frame.origin.x + shapeMarginSlider!.frame.width + 10, andWidth: 50)
        
        secondaryToolBar!.addSubview(radiusSliderLabel)
        secondaryToolBar!.addSubview(shapeRadiusSlider!)
        
        placeInCenterOfSecondToolBar(radiusSliderLabel as! UIView)
        placeInCenterOfSecondToolBar(shapeRadiusSlider as! UIView)
        
        shapeRadiusSlider!.frame.origin.x = radiusSliderLabel.frame.origin.x + radiusSliderLabel.frame.width + 5
        
        makeSliderCool(slider: shapeRadiusSlider!)
        
        shapeRadiusSlider?.value = Float( shapeRadius * 0.01 )
        shapeRadiusSlider?.minimumValue = 0.05
        
        shapeRadiusSlider!.isContinuous = false
        shapeRadiusSlider!.addTarget(self, action: #selector(self.radiusUpdated), for: .valueChanged)
        
        
        
    
    // - Cnavas - \\
        view.addSubview(drawingCanvas!)
        
        drawingCanvas!.translatesAutoresizingMaskIntoConstraints = false
        drawingCanvas!.topAnchor.constraint(equalTo: secondaryToolBar!.bottomAnchor).isActive = true
        drawingCanvas!.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        drawingCanvas!.rightAnchor.constraint(equalTo: (view.rightAnchor)).isActive = true
        drawingCanvas!.bottomAnchor.constraint(equalTo: (view.bottomAnchor)).isActive = true

        drawingCanvas!.backgroundColor = backgroundColor
        drawingCanvas!.layer.zPosition = -10
        
    
    // - PopUp - \\
        view.addSubview(popUp!)
        popUp?.show(atPosition: CGPoint(x:view.center.x, y: 500))
        
        popUp!.translatesAutoresizingMaskIntoConstraints = false
        popUp!.topAnchor.constraint(equalTo: secondaryToolBar!.bottomAnchor).isActive = true
        popUp!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popUp!.heightAnchor.constraint(equalToConstant: 50).isActive = true
        popUp!.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    // - Shape Select Menu - \\
        
        // It's being added to self.view because otherwise its children won't respond to
        // the touches since they will be out of bounds
        view.addSubview(shapeSelectMenu!)
        
        shapeSelectMenu!.frame.origin = secondaryToolBar!.frame.origin
        
    }
    
    func addEventListeners() {
        drawingCanvas!.onNewDrawingCreated = {
            if !self.undoButton!.isEnabled {
                self.undoButton?.isEnabled = true
            }
            
            if !self.createDrawingPopupDidShow {
                
                self.popUp?.changeText(to: "Yay 🎉! Try Swiping in Any Direction")
                
                self.createDrawingPopupDidShow = true
            }
            
        }
        
        drawingCanvas!.didPopulateAShape = {
            if !self.swipePopupDidShow {
                
                self.popUp?.changeText(to: "Touch and Hold Any Object To Edit")
                self.swipePopupDidShow = true
                
            }
        }
        drawingCanvas!.shapeEditingDidBegin = {
            if !self.editShapePopupDidShow {
                
            }
        }
        
        drawingCanvas!.shapeEditingDidEnd = {
            if !self.goodByePopupDidShow {
                self.popUp?.changeText(to: "You are ready! Be Creative! 😏")
                self.popUp?.hideAfter(duration: 3)
            }
        }
        
        shapeSelectMenu?.onChange = {
            self.drawingCanvas!.currentShape = self.shapeSelectMenu?.selectedItem?.value as? Shape
            self.drawingCanvas!.activeDrawing?.currentShape = self.shapeSelectMenu?.selectedItem?.value as? Shape
        }
        
        
    }
    func undo() {
        if drawingCanvas?.history.count == 1 {
            self.undoButton?.isEnabled = false
        }
        drawingCanvas?.undo()
    }
    
    func radiusUpdated(sender: UISlider) {
        let value = sender.value
        
        self.shapeRadius = CGFloat(value) * 100
        self.drawingCanvas?.shapeRadius = self.shapeRadius
        self.drawingCanvas?.activeDrawing?.shapeRadius = self.shapeRadius
    }
    
    func marginUpdated(sender: UISlider) {
        
        let value = sender.value
        
        self.shapeSpacing = CGFloat(value) * 100
        self.drawingCanvas?.shapeMargin = self.shapeSpacing
        self.drawingCanvas?.activeDrawing?.shapeMargin = self.shapeSpacing
    }
    
    public func addShape(_ shape: Shape) {
        self.shapes.append(shape)
        
        let shapeIcon = UIView(frame: shape.shapeView!.frame)
        shapeIcon.layer.cornerRadius = shape.shapeView!.layer.cornerRadius
        shapeIcon.backgroundColor = UIColor.clear
        shapeIcon.layer.borderColor = UIColor.gray.cgColor
        shapeIcon.layer.borderWidth = 1
        
        
        let menuItemView = createMenuItemView(usingView: shapeIcon, ofSize: CGSize(width: 40, height: 40))
        let menuItem = MenuItem(withView: menuItemView, value: shape)
        
        addMenuItem(item : menuItem)
    }
    
    private func addMenuItem(item : MenuItem) {
        self.shapeSelectorItems.append(item)
    }
    
    private func createMenuItemView(usingView view: UIView, ofSize size: CGSize) -> UIView {
        
        // origin is 0,0 because the drop down menu will take of it
        let menuItemView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        let viewAspectRatio = view.frame.size.width / view.frame.size.height
        let cornerRadiusRatio = view.frame.size.width / view.layer.cornerRadius
        
        view.frame.size.height = size.height / 1.7
        view.frame.size.width = view.frame.size.height * viewAspectRatio
        view.layer.cornerRadius = view.frame.size.width / cornerRadiusRatio

        view.center = menuItemView.center
        
        menuItemView.addSubview(view)
        
        return menuItemView
        
    }
    
    func makeSliderCool(slider: UISlider) {
        slider.setThumbImage(#imageLiteral(resourceName: "thumb.png"), for: .normal)
        slider.maximumTrackTintColor = rgb(210,210,210)
        slider.minimumTrackTintColor = rgb(50,50,50)

    }
    
    func makeHorizontalLabel(withText text: String, xPosition: CGFloat, andWidth width: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: xPosition, y: 5, width: width, height: width/2))
        
        label.text = text
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        label.textColor = rgb(150,150,150)
        label.sizeToFit()
        
        return label
        
    }
    
    class Popup: UILabel {
        
        var isShowing = false
        
        init(withText text: String, ofFontSize fontSize: CGFloat) {
            super.init(frame: CGRect())
            
            self.text = text
            self.textAlignment = .center
            self.font = UIFont(name: "AvenirNext-Regular", size: fontSize)
            self.textColor = rgb(150,150, 150)
            self.adjustsFontSizeToFitWidth = true
            self.isUserInteractionEnabled = false
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func show(atPosition position: CGPoint) {
            
            self.center = position
            self.frame.origin.y += 10
            self.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.frame.origin.y -= 5
                self.alpha = 1
                
            })
            
            isShowing = true
        }
        
        func hide() {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.frame.origin.y -= 5
                self.alpha = 0
                
            }, completion: {(_: Bool) in
            
                self.removeFromSuperview()
                
            })
            
            isShowing = false
        }
        
        func showWithTimer(atPosition position: CGPoint, duration: TimeInterval) {
            self.show(atPosition: position)
            
            perform(#selector(self.hide), with: nil, afterDelay: duration)
        }
        
        func hideAfter(duration: TimeInterval) {
            perform(#selector(self.hide), with: nil, afterDelay: duration)
        }
        func changeText(to newText: String) {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }, completion: {(_: Bool) in
                
                self.text = newText
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            })
        }
    }
}

//#-end-hidden-code

let interactiveCanvas = InteractiveCanvasView()

interactiveCanvas.preferredContentSize = interactiveCanvas.view.frame.size

interactiveCanvas.shapeSpacing = 2

//interactiveCanvas.colors = [];

interactiveCanvas.backgroundColor = UIColor.white

interactiveCanvas.shapeRadius = 5


//#-hidden-code
let testView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
testView.backgroundColor = UIColor.red

PlaygroundPage.current.liveView = interactiveCanvas
//#-end-hidden-code
