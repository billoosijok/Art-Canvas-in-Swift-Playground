//#-hidden-code
/**
 Created By : Belal Sejouk
 */

import UIKit
import PlaygroundSupport

let interactiveCanvas = InteractiveCanvas()

//#-end-hidden-code

/*:
 # Pattern Canvas
 Pattern Canvas is an interactive canvas that can easily create interesting patterns with few swipes.
 Combine shapes and colors and see what you come up with 😉👍
 */


//#-editable-code

// Modify the array to include your favorite colors. 
// (Initial pallet reflects WWDC17 color pallet)
interactiveCanvas.colorPallet = [#colorLiteral(red: 0.925490200519562, green: 0.235294118523598, blue: 0.10196078568697, alpha: 1.0), #colorLiteral(red: 0.584313750267029, green: 0.823529422283173, blue: 0.419607847929001, alpha: 1.0), #colorLiteral(red: 0.258823543787003, green: 0.756862759590149, blue: 0.968627452850342, alpha: 1.0), #colorLiteral(red: 0.968627452850342, green: 0.780392169952393, blue: 0.345098048448563, alpha: 1.0), #colorLiteral(red: 0.10196078568697, green: 0.278431385755539, blue: 0.400000005960464, alpha: 1.0), #colorLiteral(red: 0.937254905700684, green: 0.34901961684227, blue: 0.192156866192818, alpha: 1.0)]

interactiveCanvas.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

//#-end-editable-code

//#-hidden-code
PlaygroundPage.current.liveView = interactiveCanvas
//#-end-hidden-code
