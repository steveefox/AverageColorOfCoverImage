//
//  UIColor+Extensions.swift
//  AverageColorOfCoverImage
//
//  Created by Nikita on 27/05/2023.
//

import UIKit

extension UIColor {
	var hexString: String {
		var r:CGFloat = 0
		var g:CGFloat = 0
		var b:CGFloat = 0
		var a:CGFloat = 0
		
		getRed(&r, green: &g, blue: &b, alpha: &a)
		
		let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
		
		return String(format:"#%06x", rgb)
	}
}
