//
//  KYCircularProgress.swift
//  KYCircularProgress
//
//  Created by Y.K on 2014/10/02.
//  Copyright (c) 2014年 Yokoyama Kengo. All rights reserved.
//

import Foundation
import UIKit

// MARK: - KYCircularProgress
class KYCircularProgress: UIView {
    typealias progressChangedHandler = (_ progress: Double, _ circularView: KYCircularProgress) -> ()
    fileprivate var progressChangedClosure: progressChangedHandler?
    fileprivate var progressView: KYCircularShapeView!
    fileprivate var gradientLayer: CAGradientLayer!
    var progress: Double = 0.0 {
        didSet {
            let clipProgress = max( min(oldValue, 1.0), 0.0)
            self.progressView.updateProgress(clipProgress)
            
            if let progressChanged = progressChangedClosure {
                progressChanged(clipProgress, self)
            }
        }
    }
    var startAngle: Double = 0.0 {
        didSet {
            self.progressView.startAngle = oldValue
        }
    }
    var endAngle: Double = 0.0 {
        didSet {
            self.progressView.endAngle = oldValue
        }
    }
    var lineWidth: Double = 8.0 {
        willSet {
            self.progressView.shapeLayer().lineWidth = CGFloat(newValue)
        }
    }
    var path: UIBezierPath? {
        willSet {
            self.progressView.shapeLayer().path = newValue?.cgPath
        }
    }
    var colors: [Int]? {
        didSet {
            updateColors(oldValue)
        }
    }
    var progressAlpha: CGFloat = 0.55 {
        didSet {
            updateColors(self.colors)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    fileprivate func setup() {
        self.progressView = KYCircularShapeView(frame: self.bounds)
        self.progressView.shapeLayer().fillColor = UIColor.clear.cgColor
        self.progressView.shapeLayer().path = self.path?.cgPath
        
        gradientLayer = CAGradientLayer(layer: layer)
        gradientLayer.frame = self.progressView.frame
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5);
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5);
        gradientLayer.mask = self.progressView.shapeLayer();
        gradientLayer.colors = self.colors ?? [colorHex(0x9ACDE7).cgColor, colorHex(0xE7A5C9).cgColor]
        
        self.layer.addSublayer(gradientLayer)
        self.progressView.shapeLayer().strokeColor = self.tintColor.cgColor
    }
    
    func progressChangedClosure(_ completion: @escaping progressChangedHandler) {
        progressChangedClosure = completion
    }
    
    fileprivate func colorHex(_ rgb: Int) -> UIColor {
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgb & 0xFF00) >> 8) / 255.0,
                       blue: CGFloat(rgb & 0xFF) / 255.0,
                       alpha: progressAlpha)
    }
    
    fileprivate func updateColors(_ colors: [Int]?) -> () {
        var convertedColors: [AnyObject] = []
        if let inputColors = self.colors {
            for hexColor in inputColors {
                convertedColors.append(self.colorHex(hexColor).cgColor)
            }
        } else {
            convertedColors = [self.colorHex(0x9ACDE7).cgColor, self.colorHex(0xE7A5C9).cgColor]
        }
        self.gradientLayer.colors = convertedColors
    }
}

// MARK: - KYCircularShapeView
class KYCircularShapeView: UIView {
    var startAngle = 0.0
    var endAngle = 0.0
    
    override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    fileprivate func shapeLayer() -> CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateProgress(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.startAngle == self.endAngle {
            self.endAngle = self.startAngle + (M_PI * 2)
        }
        self.shapeLayer().path = self.shapeLayer().path ?? self.layoutPath().cgPath
    }
    
    fileprivate func layoutPath() -> UIBezierPath {
        let halfWidth = CGFloat(self.frame.size.width / 2.0)
        return UIBezierPath(arcCenter: CGPoint(x: halfWidth, y: halfWidth), radius: halfWidth - self.shapeLayer().lineWidth, startAngle: CGFloat(self.startAngle), endAngle: CGFloat(self.endAngle), clockwise: true)
    }
    
    fileprivate func updateProgress(_ progress: Double) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.shapeLayer().strokeEnd = CGFloat(progress)
        CATransaction.commit()
    }
}
