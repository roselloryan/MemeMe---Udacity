import Foundation
import UIKit

struct Placeholder {
    
    static let topText = "TOP TEXT"
    static let bottomText = "BOTTOM TEXT"
}

var fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40

var kdefaultFontName: String = "Impact" {

    didSet {
        print("default font: \(String(describing: kDefaultFont))")

        kDefaultFont = UIFont(name: kdefaultFontName, size: fontSize)!
    }
}


var kDefaultFont = UIFont(name: kdefaultFontName, size: fontSize) {
    
    didSet {
        print("Just got set to: \(kdefaultFontName)")
    }
}


let kPreferredFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 17)

let kImpactFontName = "Impact"


let kDetailVCstoryboardID = "memeDetailViewController"
let kEditorVCStoryboardID = "mainViewController"
