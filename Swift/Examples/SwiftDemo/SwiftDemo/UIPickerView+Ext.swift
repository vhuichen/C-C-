//
//  UIPickerView+Ext.swift
//  SwiftDemo
//
//  Created by ChenHui on 2024/8/8.
//

import UIKit

/*
 不要使用 self.value(forKey: "") 获取对应的View，原因：无法兼容所有版本，如果 key 不存在会崩溃
 方案：找到符合预期的View，没有找到则不处理
 已适配系统：14.2、15.0、16.0、17.2
 */
public extension UIPickerView {
    // 中间选中行背景色
    func vch_setSelectViewBgColor(_ color: UIColor) {
        guard let foregroundView = self.subviews.first else {
            return
        }
        
        guard let firstColumnView = foregroundView.subviews.first,
              String(describing: type(of: firstColumnView)) == "UIPickerColumnView"
        else {
            return
        }
        
        guard firstColumnView.subviews.count == 3 else {
            return
        }
        
        let topContainerView = firstColumnView.subviews[0]
        let bottomContainerView = firstColumnView.subviews[1]
        let middleContainerView = firstColumnView.subviews[2]
        
        guard topContainerView.bounds.size.height == bottomContainerView.bounds.size.height,
              String(describing: type(of: middleContainerView)) == "UIView",
              middleContainerView.subviews.count == 1,
              let middleTable = middleContainerView.subviews.first,
              String(describing: type(of: middleTable)) == "UIPickerTableView"
        else {
            return
        }
        
        middleContainerView.backgroundColor = color
    }
    
    // 隐藏蒙层
    func vch_hiddenMaskView() {
        vch_hiddenTopLineOrFillView()
        vch_hiddenMaskGradientLayer()
    }
    
    func vch_hiddenTopLineOrFillView() {
        // topLineOrFillView
        guard self.subviews.count == 2,
              let topLineOrFillView = self.subviews.last,
              String(describing: type(of: topLineOrFillView)) == "UIView",
              topLineOrFillView.subviews.count == 0
        else {
            return
        }
        
        topLineOrFillView.isHidden = true
    }
    
    func vch_hiddenMaskGradientLayer() {
        // CAGradientLayer -- maskGradientLayer
        guard let foregroundView = self.subviews.first,
              String(describing: type(of: foregroundView)) == "UIView",
              let maskGradientLayer = foregroundView.layer.sublayers?.last as? CAGradientLayer
        else {
            return
        }
        maskGradientLayer.isHidden = true
    }
    
    func vch_setRightMaskLayer(layer: CALayer) {
        guard let foregroundView = self.subviews.first else {
            return
        }
        
        guard let firstColumnView = foregroundView.subviews.first,
              String(describing: type(of: firstColumnView)) == "UIPickerColumnView"
        else {
            return
        }
        
        guard firstColumnView.subviews.count == 3 else {
            return
        }
        
        var frame = firstColumnView.layer.bounds
        frame.origin.x = frame.size.width / 2.0 - 15
        frame.size.width = frame.size.width - frame.origin.x
        layer.frame = frame
        
        firstColumnView.layer.insertSublayer(layer, at: 0)
    }
}
