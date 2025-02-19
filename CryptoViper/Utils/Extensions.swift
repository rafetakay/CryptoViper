//
//  Extensions.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 28.01.2025.
//

import Foundation
import UIKit


extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop:CGFloat = 0,
                paddingLeft:CGFloat = 0,
                paddingBottom:CGFloat = 0,
                paddingRight:CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false// programmatic autolayout yapabilmemk icin
        
        //active yapıyoruz
        if let top = top {
            topAnchor.constraint(equalTo: top,constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left,constant: paddingLeft).isActive = true
            
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom,constant: -paddingBottom).isActive = true
            //negatfi veriyoruz padding bottoma
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right,constant: -paddingRight).isActive = true
            //negatfi veriyoruz padding lefte cunku sola hareket etmesi icin verdikce padding i
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
        
    }
    
    
}
