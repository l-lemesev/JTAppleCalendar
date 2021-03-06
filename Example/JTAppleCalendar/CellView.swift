//
//  CellView.swift
//  testApplicationCalendar
//
//  Created by Jay Thomas on 2016-03-04.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


import JTAppleCalendar

class CellView: JTAppleDayCellView {
    @IBInspectable var todayColor: UIColor!// = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
    @IBInspectable var normalDayColor: UIColor! //UIColor(white: 0.0, alpha: 0.1)
    @IBOutlet var selectedView: AnimationView!
    @IBOutlet var dayLabel: UILabel!
    
    let textSelectedColor = UIColor.whiteColor()
    let textDeselectedColor = UIColor.blackColor()
    let previousMonthTextColor = UIColor.grayColor()
    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.c.stringFromDate(NSDate())
        return aString
    }()
    lazy var c : NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        
        return f
    }()
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        // Setup Cell text
        dayLabel.text =  cellState.text
        
        // Setup text color
        configureTextColor(cellState)

        // Setup Cell Background color
        self.backgroundColor = c.stringFromDate(date) == todayDate ? todayColor:normalDayColor
        
        // Setup cell selection status
        configueViewIntoBubbleView(cellState)
        
        // Configure Visibility
        configureVisibility(cellState)
    }
    
    func configureVisibility(cellState: CellState) {
        if
            cellState.dateBelongsTo == .ThisMonth ||
            cellState.dateBelongsTo == .PreviousMonthWithinBoundary ||
            cellState.dateBelongsTo == .FollowingMonthWithinBoundary {
            self.hidden = false
        } else {
            self.hidden = false
        }
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.isSelected {
            dayLabel.textColor = textSelectedColor
        } else if cellState.dateBelongsTo == .ThisMonth {
            dayLabel.textColor = textDeselectedColor
        } else {
            dayLabel.textColor = previousMonthTextColor
        }
    }
    
    func cellSelectionChanged(cellState: CellState) {
        if cellState.isSelected == true {

            if selectedView.hidden == true {
                configueViewIntoBubbleView(cellState)
                self.userInteractionEnabled = false
                selectedView.animateWithBounceEffect(withCompletionHandler: {
                    self.userInteractionEnabled = true
                })
            }
        } else {
            configueViewIntoBubbleView(cellState, animateDeselection: true)
        }
    }
    
    private func configueViewIntoBubbleView(cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {

            delayRunOnMainThread(0.0, closure: { 
                self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
                self.selectedView.hidden = false
            })

            configureTextColor(cellState)
            
        } else {
            if animateDeselection {
                configureTextColor(cellState)
                if selectedView.hidden == false {
                    self.userInteractionEnabled = false
                    selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.userInteractionEnabled = true
                        self.selectedView.hidden = true
                        self.selectedView.alpha = 1
                    })
                }
            } else {
                selectedView.hidden = true
            }
        }
    }
    
    func delayRunOnMainThread(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

class AnimationView: UIView {

    func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
        AnimationClass.flipAnimation(self, completion: completionHandler)
    }
    func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self){ _ in
            completionHandler?()
        }
    }
    func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.FadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}