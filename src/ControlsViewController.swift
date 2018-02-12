//
//  ControlsViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

import Foundation
import UIKit

class ControlsViewController : UIViewController,
UITextViewDelegate,
AboutViewControllerDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewCancel: UIButton!
    @IBOutlet var textBackgroundView: UIView!
    

    private var brushViewController: BrushSelectionViewController?
    private var aboutViewController: AboutViewController?

    let images = [Brush(name: "Charlock", imageName: "charlock"),
                  Brush(name: "Cleaver", imageName: "cleaver"),
                  Brush(name: "Maize", imageName: "maize"),
                  Brush(name: "Shepards purse", imageName: "shepards purse"),
                  Brush(name: "Fat Hen", imageName: "fat hen"),
                  Brush(name: "Sugar Beet", imageName: "sugar beet"),
                  Brush(name: "Maize", imageName: "maize")]

    @objc var app: ofAppAdapter?
    private var currentString: String?

    private var isDrawerOpen: Bool {
        guard let alpha = brushViewController?.view.alpha else { return false }
        return alpha > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextView()
        setUpBrushSelection()
        hideBrushSelection(animated: false)

        if let controlView = view as? ControlView {
            controlView.controller = self
        }
    }

    private func setUpTextView() {
        hideTextView(animated: false)
    }

    private func setUpBrushSelection() {
        guard let app = app else { return }
        let controller = BrushSelectionViewController(withApp: app, brushes: images)
        controller.delegate = self
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.autoPinEdgesToSuperviewEdges()
        brushViewController = controller
    }

    @IBAction func didTapOpenDrawer() {
        if (isDrawerOpen) {
            hideBrushSelection()
        } else {
            showBrushSelection()
        }
    }

    private func hideBrushSelection(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: {
                        self.brushViewController?.view.alpha = 0.0
        }, completion: { finished in
        })
    }

    @objc func showBrushSelection() {
        brushViewController?.viewWillAppear(true)
        UIView.animate(withDuration: 0.3)  {
            self.brushViewController?.view.alpha = 1.0
        }
    }

    private func hideAbout() {
        guard let aboutViewController = aboutViewController else { return }
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       animations: {
                        aboutViewController.view.alpha = 0.0

        }) { finished in
            aboutViewController.removeFromParentViewController()
            self.aboutViewController = nil
        }
    }

    @IBAction func showAbout() {
        guard self.aboutViewController == nil else { return }

        let aboutViewController = AboutViewController(nibName: nil, bundle: nil)
        aboutViewController.delegate = self
        self.aboutViewController = aboutViewController
        self.addChildViewController(aboutViewController)
        aboutViewController.view.alpha = 0.0
        view.addSubview(aboutViewController.view)
        aboutViewController.view.autoPinEdgesToSuperviewEdges()

        UIView.animate(withDuration: 0.3,
                       animations: {
                        aboutViewController.view.alpha = 1.0
        })
    }

    private func hideTextView(animated: Bool = true) {
        textView.resignFirstResponder()
        UIView.animate(withDuration: animated ? 0.3 : 0.0)  {
            self.textBackgroundView.alpha = 0.0
        }

    }
    private func showTextView() {
        UIView.animate(withDuration: 0.3)  {
            self.textBackgroundView.alpha = 1.0
        }
    }
    
    @IBAction func didTapTestText() {
        textView.text = currentString
        hideBrushSelection()
        showTextView()
        textView.becomeFirstResponder()
    }

    @IBAction func didTapCloseText() {
        hideTextView()
    }

    // MARK: AboutViewControllerDelegate

    func aboutViewControllerDidTapClose(_ controller: AboutViewController) {
        hideAbout()
    }

    // MARK: UITextViewDelegate

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            app?.setText(textView.text)
            currentString = textView.text
            hideTextView()
            return false
        }
        return true
    }

    // MARK: ControlView handling
    func shouldHandleTouch() -> Bool {
        return textView.isFirstResponder
    }

    func handleTouch() {
        if textView.isFirstResponder {
            hideTextView()
        }
    }
}
extension ControlsViewController : BrushSelectionViewControllerDelegate {
    func brushSelectionViewControllerDidSelectBrush(_ controller: BrushSelectionViewController,
                                                    at index: Int) {
        app?.setMode(Int32(index))
        hideBrushSelection()
    }

    func brushSelectionViewControllerDidTapClose(_ controller: BrushSelectionViewController) {
        hideBrushSelection()
    }
}

class ControlView: UIView {
    weak var controller: ControlsViewController?

    var touch: UITouch?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let controller = controller else { return }
        controller.handleTouch()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        guard let controller = controller else { return nil }

        if self == view {
            if controller.shouldHandleTouch() {
                return view
            }
        } else if view.isDescendant(of: self) {
            return view
        }
        return nil
    }
}
