

import UIKit

public class InteractiveCanvasView: UIView, UIScrollViewDelegate {
    
    // MARK: UI Elements
    public var toolBar: UIView?
    public var drawingCanvas: DrawingCanvasView?
    public var colorPicker: colorPickerView?
    public var undoButton: UIButton?
    let undoImage : UIImage = #imageLiteral(resourceName: "undo@3x.png")
    
    // MARK: Properties
    public var colors = [UIColor]();
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(frame: CGRect, canvasColors: [UIColor]?) {
        
        if let colors = canvasColors {
            if colors.count == 0 {
                self.colors = [rgb(0,0,0), rgb(255,255,255)]
            } else {
                self.colors = colors
            }
            
            
        } else {
            self.colors = [
                rgb(255,182,30),  rgb(108,122,137),
                rgb(217,182,17),  rgb(77,175,124),
                rgb(249,105,14),  rgb(38,67,72),
                rgb(13, 65, 94),  rgb(198,116, 91),
                rgb(0, 118,127),  rgb(0, 84, 127),
            ];
        }
        
        super.init(frame: frame)
        
        sceneSetup()
        
    }
    
    //    override public func layoutSubviews() {
    //        super.layoutSubviews()
    //
    //        toolBar!.frame.size.width = self.frame.width
    //        addBorder(to: toolBar!, on: .bottom, ofWidth: 0.5, andColor: UIColor(white: 0, alpha: 1))
    //
    //        colorPicker!.frame = CGRect(x: undoButton!.frame.width + undoButton!.frame.origin.x, y: 0, width: self.frame.width - undoButton!.frame.width, height: toolBar!.frame.height)
    //    }
    
    private func sceneSetup() {
        
        
        
        toolBar = UIView(frame : CGRect(x: 0, y: 0, width: self.frame.width, height: 70));
        toolBar?.backgroundColor = UIColor.white
        self.addSubview(toolBar!)
        
        undoButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: toolBar!.frame.height, height: toolBar!.frame.height)))
        addBorder(to: undoButton as! UIView, on: .right, ofWidth: 0.5, andColor: rgb(0,0,0))
        //        undoButton?.setTitle("Undo", for: .normal)
        undoButton?.setImage(undoImage, for: .normal)
        let imagePadding = undoButton!.frame.size.width / 4
        undoButton?.imageEdgeInsets = UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: imagePadding)
        undoButton?.setTitleColor(rgb(0,0,155), for: .normal)
        undoButton?.setTitleColor(rgb(50,50,195), for: .highlighted)
        
        undoButton?.addTarget(self, action: #selector(self.undo), for: .touchUpInside)
        
        toolBar?.addSubview(undoButton!)
        
        colorPicker = colorPickerView(frame : CGRect(x: undoButton!.frame.width + undoButton!.frame.origin.x, y: 0, width: self.frame.width - undoButton!.frame.width, height: 70), colors: self.colors)
        
        toolBar!.addSubview(colorPicker!)
        
        
        drawingCanvas = DrawingCanvasView(frame: CGRect(x: 0, y: toolBar!.frame.origin.y + toolBar!.frame.height, width: self.frame.width, height:self.frame.height - toolBar!.frame.height), shapes: [], colorPicker: colorPicker!)
        
        self.addSubview(drawingCanvas!)
        
        
    }
    
    func undo() {
        drawingCanvas?.activeDrawing?.undo()
    }
    
//    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
////        return self.drawingCanvas as? UIView
//    }
    
    
}
