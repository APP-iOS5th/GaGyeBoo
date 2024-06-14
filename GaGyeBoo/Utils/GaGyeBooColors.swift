import UIKit

extension UIColor {
    static let paperColor = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0) // #F5F5DC
    static let softColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)  // #F0F0F0
    static let warmColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1.0)  // #E4E4E4
    static let brightColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0) // #D3D3D3
    static let lightColor = UIColor(red: 201/255, green: 201/255, blue: 201/255, alpha: 1.0)  // #C9C9C9
    static let primary100 = UIColor(red: 1/255, green: 155/255, blue: 152/255, alpha: 1.0)  // #019b98
    static let primary200 = UIColor(red: 85/255, green: 204/255, blue: 201/255, alpha: 1.0)  // #55ccc9
    static let primary300 = UIColor(red: 193/255, green: 255/255, blue: 255/255, alpha: 1.0)  // #c1ffff
    static let accent100 = UIColor(red: 221/255, green: 0/255, blue: 37/255, alpha: 1.0)  // #dd0025
    static let accent200 = UIColor(red: 255/255, green: 191/255, blue: 171/255, alpha: 1.0)  // #ffbfab
    static let text100 = UIColor(red: 1/255, green: 78/255, blue: 96/255, alpha: 1.0)  // #014e60
    static let text200 = UIColor(red: 63/255, green: 122/255, blue: 141/255, alpha: 1.0)  // #3f7a8d
    static let bg100 = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)  // #fbfbfb
    static let bg200 = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)  // #f1f1f1
    static let bg300 = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)  // #c8c8c8
    static let tempBlue = UIColor(red: 0, green: 112/255, blue: 192/255, alpha: 1)
    static let tempBlue2 = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    static let textBlue = UIColor(red: 0/255, green: 119/255, blue: 194/255, alpha: 1)
    static let linen = UIColor(red: 250/255, green: 240/255, blue: 230/255, alpha: 1.0)
    static let whitePaper = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    // Hex -> UIColor
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        
        switch length {
        case 6: // RGB (24bit)
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA (32bit)
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
