//#-hidden-code
//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


class InteractiveCanvas: UIViewController {
    
    var shapeSpacing: CGFloat = 10
    var colors : [UIColor]?;
    var backgroundColor = UIColor.white
    var shapeRadius : CGFloat = 10
    var shapes = [Any]()
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        let interactiveView = InteractiveCanvasView(frame: self.view.frame, canvasColors:self.colors )
        interactiveView.backgroundColor = self.backgroundColor
        
        
        interactiveView.drawingCanvas?.shapeMargin = self.shapeSpacing
        interactiveView.drawingCanvas?.shapeRadius = self.shapeRadius;

        self.view.backgroundColor = backgroundColor
        self.view.addSubview(interactiveView)
        
    }
}

//#-end-hidden-code

let interactiveCanvas = InteractiveCanvas()

interactiveCanvas.shapeSpacing = 2

//interactiveCanvas.colors = [];

interactiveCanvas.backgroundColor = UIColor.white

interactiveCanvas.shapeRadius = 5


//#-hidden-code
PlaygroundPage.current.liveView = interactiveCanvas
//#-end-hidden-code
