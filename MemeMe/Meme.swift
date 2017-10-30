import Foundation
import UIKit

struct Meme {
    let topText: String?
    let bottomText: String?
    let originalImage: UIImage
    let memedImage: UIImage
    
    
    // Needed to lauch editor from already created meme
    let fontName: String
    let imageOffset: CGPoint
    let zoomScale: CGFloat
}

extension Meme: Equatable {
    
    static func == (lhs: Meme, rhs: Meme) -> Bool {
        
        return lhs.topText == rhs.topText &&
                lhs.bottomText == rhs.bottomText &&
                lhs.originalImage == rhs.originalImage &&
                lhs.memedImage == rhs.memedImage &&
                lhs.fontName == rhs.fontName &&
                lhs.imageOffset == rhs.imageOffset &&
                lhs.zoomScale == rhs.zoomScale
    }
}
