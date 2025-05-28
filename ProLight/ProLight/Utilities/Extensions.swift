//
//  Extensions.swift
//  ProLight
//
//  Created by Paul on 6/24/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import UIKit

extension UIViewController {
    // MARK: alert view
    func simpleAlert(title: String, message: String, buttonTitle: String, style: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: style, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: coppyright text
    func yearFormatter(labelName: UILabel) {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        labelName.text = "© \(currentYear) Studio 4 Design Software"
    }
    
    func getVersion() -> String {
        let kVersion = "CFBundleShortVersionString"
        let kBuildNumber = "CFBundleVersion"
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        let build = dictionary[kBuildNumber] as! String
        return "\(version) (\(build))"
    }
    
    func getYear() -> String {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        return "\(currentYear)"
    }
    
    // MARK: button vibration
    func buttonVibration(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func UIViewSetup(view: UIView) {
        view.layer.borderColor = Theme.current.Appearance.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.alpha = 0
        view.isHidden = true
    }
    
    func viewBorder(borderView: UIView, width: CGFloat, radius: CGFloat, bounds: Bool) {
        borderView.layer.borderWidth = width
        borderView.layer.cornerRadius = radius
        borderView.clipsToBounds = bounds
    }
    
    func viewShadow(view: UIView, radius: CGFloat, opacity: Float, color: UIColor) {
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
        view.layer.shadowColor = color.cgColor
    }
}

// MARK: extensions
extension Bundle {
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleName") as! String
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
