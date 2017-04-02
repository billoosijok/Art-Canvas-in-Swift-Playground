

import UIKit
import AVFoundation

public class InteractiveCanvas: UIViewController {
    
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
    
    // MARK: Sound Properties
    var newDrawingSound : AVAudioPlayer?
    var undoSound : AVAudioPlayer?
    var deleteDrawingSound : AVAudioPlayer?
    
    // MARK: Properties
    public var colors = [UIColor]();
    public var shapeSpacing: CGFloat = 10
    public var backgroundColor = UIColor.white
    public var shapeSize : CGFloat = 20
    
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
        
        let shape1 = Shape(ofType: .square, size: CGSize(width: 50, height: 50), margin: 2, color: UIColor.blue)
        let shape2 = Shape(ofType: .circle, size: CGSize(width: 50, height: 50), margin: 2, color: UIColor.blue)
        
        addShape(shape1)
        addShape(shape2)
        
        initUI()
        sceneSetup()
        initSounds()
        addEventListeners()
        
        self.drawingCanvas?.shapeMargin = self.shapeSpacing
        self.drawingCanvas?.shapeRadius = self.shapeSize;
        
    }
    
    /**
     Initializes all UI elements in the View Controller
     */
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
    
    /**
     Sets up UI elements in the view controller. It also applies constraits for all of them.
     */
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
                toolBar!.addSubview(undoButton!)
        
                undoButton!.translatesAutoresizingMaskIntoConstraints = false
                undoButton!.leftAnchor.constraint(equalTo: toolBar!.leftAnchor).isActive = true
                undoButton!.topAnchor.constraint(equalTo: toolBar!.topAnchor).isActive = true
                undoButton!.heightAnchor.constraint(equalTo: (toolBar!.heightAnchor)).isActive = true
                undoButton!.widthAnchor.constraint(equalToConstant: (toolBar!.frame.height)).isActive = true
        
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
        colorPicker!.leftAnchor.constraint(equalTo: undoButton!.rightAnchor).isActive = true
        colorPicker!.topAnchor.constraint(equalTo: toolBar!.topAnchor).isActive = true
        colorPicker!.heightAnchor.constraint(equalTo: (toolBar!.heightAnchor)).isActive = true
        colorPicker!.rightAnchor.constraint(equalTo: (toolBar!.rightAnchor)).isActive = true
        
        
    // - Secondary Tool Bar - \\
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
        
        shapeRadiusSlider?.value = Float( shapeSize * 0.01 )
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
    
    /**
     Initializes sound players
     */
    func initSounds() {
        do {
            newDrawingSound = try AVAudioPlayer(contentsOf: URL(fileReferenceLiteralResourceName: "pop.wav"))
            undoSound = try AVAudioPlayer(contentsOf: URL(fileReferenceLiteralResourceName: "undo.wav"))
            deleteDrawingSound = try AVAudioPlayer(contentsOf: URL(fileReferenceLiteralResourceName: "trash.wav"))
            
        } catch {
            print("\(error)")
        }
    }
    /**
     Adding functionalities to run when events occur on canvas. Mostly, for the introductiory popups.
     */
    func addEventListeners() {
        drawingCanvas!.onNewDrawingCreated = {
            if !self.undoButton!.isEnabled {
                self.undoButton?.isEnabled = true
            }
            
            if !self.createDrawingPopupDidShow {
                
                self.popUp?.changeText(to: "Yay 🎉! Try Swiping in Any Direction")
                
                self.createDrawingPopupDidShow = true
            }
            self.newDrawingSound?.currentTime = 0
            self.newDrawingSound?.play()
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
        
        drawingCanvas!.drawingDidDelete = {
            self.deleteDrawingSound?.currentTime = 0
            self.deleteDrawingSound?.play()
        }
        
        shapeSelectMenu?.onChange = {
            self.drawingCanvas!.currentShape = self.shapeSelectMenu?.selectedItem?.value as? Shape
            self.drawingCanvas!.activeDrawing?.currentShape = self.shapeSelectMenu?.selectedItem?.value as? Shape
        }
        
        
    }
    
    /**
     Undoes the last move.
     */
    func undo() {
        // if there si only one left that means this undo call is going to remove it
        // so we disable the undo button
        if drawingCanvas?.history.count == 1 {
            self.undoButton?.isEnabled = false
        }
        undoSound?.currentTime = 0
        undoSound?.play()
        drawingCanvas?.undo()
    }
    
    /**
     Responds to the change in Size Slider by updating the size value.
     */
    func radiusUpdated(sender: UISlider) {
        let value = sender.value
        
        self.shapeSize = CGFloat(value) * 200
        self.drawingCanvas?.shapeRadius = self.shapeSize
        self.drawingCanvas?.activeDrawing?.shapeRadius = self.shapeSize
    }
    
    /**
     Responds to the change in Margin Slider by updating the margin value.
     */
    func marginUpdated(sender: UISlider) {
        
        let value = sender.value
        
        self.shapeSpacing = CGFloat(value) * 200
        self.drawingCanvas?.shapeMargin = self.shapeSpacing
        self.drawingCanvas?.activeDrawing?.shapeMargin = self.shapeSpacing
    }
    
    /**
     Created to provide an interface of adding a new shape to the canvas.
     
     - parameter shape: An instance of `Shape`.
     */
    public func addShape(_ shape: Shape) {
        self.shapes.append(shape)
        
        // Creating an icon for the passed shape.
        let shapeIcon = UIView(frame: shape.shapeView!.frame)
        shapeIcon.layer.cornerRadius = shape.shapeView!.layer.cornerRadius
        shapeIcon.backgroundColor = UIColor.clear
        shapeIcon.layer.borderColor = UIColor.gray.cgColor
        shapeIcon.layer.borderWidth = 1
        
        // Using the icon to create a menu item.
        let menuItemView = createMenuItemView(usingView: shapeIcon, ofSize: CGSize(width: 40, height: 40))
        let menuItem = MenuItem(withView: menuItemView, value: shape)
        
        addMenuItem(item : menuItem)
    }
    
    /**
     Adds a menu item to the array of menu items in the shape selector drop down.
     
     - parameter item : A `MenuItem` instance to add to the array.
     */
    private func addMenuItem(item : MenuItem) {
        self.shapeSelectorItems.append(item)
    }
    
    /**
     This is a helper function that creates a MenuItem for the drop down menu.
     
     - parameter view: The view you'd like to show on the Menu Item.
     - parameter size: The size of the menu item.
     
     - returns: A view that incapsulates the view passed. This view can then be used 
                to create an instance of `struct MenuItem` to pass it to the Drop Down class.
     */
    private func createMenuItemView(usingView view: UIView, ofSize size: CGSize) -> UIView {
        
        // origin is 0,0 because the drop down menu will take care of it.
        let menuItemView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        // Keeping track of the ratios of the view's width and height. Also
        // between the corner radius and width (for rounded corners)
        let viewAspectRatio = view.frame.size.width / view.frame.size.height
        let cornerRadiusRatio = view.frame.size.width / view.layer.cornerRadius
        
        // Now shrinking down the passed view to fit the menu item.
        // Using the ratios to resize them properly.
        view.frame.size.height = size.height / 1.7
        view.frame.size.width = view.frame.size.height * viewAspectRatio
        view.layer.cornerRadius = view.frame.size.width / cornerRadiusRatio
        
        // Then centering the view inside the menu item view.
        view.center = menuItemView.center
        
        // Then, finally, adding the view the menu item view.
        menuItemView.addSubview(view)
        
        return menuItemView
        
    }
    
    /**
     Simply modifies a `UISlider` to fit the theme of the app
     */
    func makeSliderCool(slider: UISlider) {
        slider.setThumbImage(#imageLiteral(resourceName: "thumb.png"), for: .normal)
        slider.maximumTrackTintColor = rgb(210,210,210)
        slider.minimumTrackTintColor = rgb(50,50,50)
    }
    
    /**
     It helps to easily create a horizontal label for UI controls in the tool bar. The position of the 
     label in y axis is 0. Also the height defaults to half of the width, to create 2:1 aspect ratio.
     
     - parameter text : The text on the label.
     - parameter xPosition : The origin of the label in the x axis
     - parameter width : The width of the label.
     
     - returns: `UILabel` with the following properties:
        - Font "System-Ultrathin".
        - Text alignment center.
        - Text color of rgb(150,150,150)
        - The size of the label may increase / decrease depending on the amount of text.
     */
    func makeHorizontalLabel(withText text: String, xPosition: CGFloat, andWidth width: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: xPosition, y: 0, width: width, height: width/2))
        
        label.text = text
        label.textAlignment = .center
        label.font = UIFont(name: "System-Ultrathin", size: 15)
        label.textColor = rgb(150,150,150)
        label.sizeToFit()
        
        return label
        
    }
}
