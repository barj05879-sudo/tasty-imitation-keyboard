//
//  ViewController.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

class HostingAppViewController: UIViewController {

    @IBOutlet var stats: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HostingAppViewController.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HostingAppViewController.keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HostingAppViewController.keyboardDidChangeFrame(_:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func dismiss() {
        for view in self.view.subviews {
            if let inputView = view as? UITextField {
                inputView.resignFirstResponder()
            }
        }
    }

    var startTime: TimeInterval?
    var firstHeightTime: TimeInterval?
    var secondHeightTime: TimeInterval?
    var referenceHeight: CGFloat = 216

    @objc func keyboardWillShow() {
        if startTime == nil {
            startTime = CACurrentMediaTime()
        }
    }

    @objc func keyboardDidHide() {
        startTime = nil
        firstHeightTime = nil
        secondHeightTime = nil
        stats?.text = "(Waiting for keyboard...)"
    }

    @objc func keyboardDidChangeFrame(_ notification: Notification) {
        guard let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        if frameEnd.height == referenceHeight {
            if firstHeightTime == nil {
                firstHeightTime = CACurrentMediaTime()

                if let startTime = startTime,
                   let firstHeightTime = firstHeightTime {
                    let formatString = NSString(format: "First: %.2f, Total: %.2f", firstHeightTime - startTime, firstHeightTime - startTime)
                    stats?.text = formatString as String
                }
            }
        } else if frameEnd.height != 0 {
            if secondHeightTime == nil {
                secondHeightTime = CACurrentMediaTime()

                if let startTime = startTime,
                   let firstHeightTime = firstHeightTime,
                   let secondHeightTime = secondHeightTime {
                    let formatString = NSString(format: "First: %.2f, Second: %.2f, Total: %.2f", firstHeightTime - startTime, secondHeightTime - firstHeightTime, secondHeightTime - startTime)
                    stats?.text = formatString as String
                }
            }
        }
    }
}
