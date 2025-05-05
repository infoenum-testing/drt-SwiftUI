
import UIKit

extension UIFont {
    static func verlagBook(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Verlag-Book", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func verlagBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Verlag-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func verlagBlack(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Verlag-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
    }
}

