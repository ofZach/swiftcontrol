//
//  ControlsViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

import Foundation
import UIKit

class ControlsViewController : UIViewController,
AboutViewControllerDelegate {

    private var brushViewController: BrushSelectionViewController?
    private var aboutViewController: AboutViewController?
    private var textInputViewController: TextInputViewController =
        TextInputViewController(nibName: String(describing: TextInputViewController.self),
                                bundle: nil)

    let images = [Brush(name: "Charlock", imageName: "charlock"),
                  Brush(name: "Cleaver", imageName: "cleaver"),
                  Brush(name: "Maize", imageName: "maize"),
                  Brush(name: "Shepards purse", imageName: "shepards purse"),
                  Brush(name: "Fat Hen", imageName: "fat hen"),
                  Brush(name: "Sugar Beet", imageName: "sugar beet"),
                  Brush(name: "Maize", imageName: "maize")]

    @objc var app: ofAppAdapter?

    private var isDrawerOpen: Bool {
        guard let alpha = brushViewController?.view.alpha else { return false }
        return alpha > 0
    }

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextInput()
        setUpBrushSelection()
    }


    private func setUpBrushSelection() {
        guard let app = app else { return }
        let controller = BrushSelectionViewController(withApp: app, brushes: images)
        controller.delegate = self
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.autoPinEdgesToSuperviewEdges()
        brushViewController = controller
        hideBrushSelection(animated: false)
    }

    private func setUpTextInput() {
        guard let app = app else { return }
        textInputViewController.delegate = self
        textInputViewController.app = app
        addChildViewController(textInputViewController)
        view.addSubview(textInputViewController.view)
        textInputViewController.view.autoPinEdgesToSuperviewEdges()
        hideTextInput(animated: false)
    }

    @IBAction func didTapOpenDrawer() {
        if (isDrawerOpen) {
            hideBrushSelection()
        } else {
            showBrushSelection()
        }
    }

    private func hideBrushSelection(animated: Bool = true) {
        guard let brushViewController = brushViewController else { return }
        brushViewController.beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: {
                        brushViewController.view.alpha = 0.0
        }, completion: { finished in
            brushViewController.endAppearanceTransition()
        })
    }

    @objc func showBrushSelection() {
        guard let brushViewController = brushViewController else { return }
        brushViewController.beginAppearanceTransition(true, animated: true)
        UIView.animate(withDuration: 0.3, animations:  {
            brushViewController.view.alpha = 1.0
        }, completion: { finished in
            brushViewController.endAppearanceTransition()
        })
    }

    private func hideAbout() {
        guard let aboutViewController = aboutViewController else { return }
        aboutViewController.beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       animations: {
                        aboutViewController.view.alpha = 0.0

        }) { finished in
            aboutViewController.endAppearanceTransition()
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
        aboutViewController.beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        aboutViewController.view.alpha = 1.0
        }, completion: { finished in
            aboutViewController.endAppearanceTransition()
        })
    }

    private func hideTextInput(animated: Bool = true) {
        textInputViewController.beginAppearanceTransition(false, animated: animated)
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.textInputViewController.view.alpha = 0.0
        }, completion: { finished in
            self.textInputViewController.endAppearanceTransition()
        })

    }
    private func showTextInput() {
        textInputViewController.beginAppearanceTransition(true, animated: true)
        UIView.animate(withDuration: 0.3, animations:  {
            self.textInputViewController.view.alpha = 1
        }, completion: { finished in
            self.textInputViewController.endAppearanceTransition()
        })
    }
    
    @IBAction func didTapTestText() {
        hideBrushSelection()
        showTextInput()
    }


    // MARK: AboutViewControllerDelegate

    func aboutViewControllerDidTapClose(_ controller: AboutViewController) {
        hideAbout()
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

extension ControlsViewController : TextInputViewControllerDelegate {
    func textInputViewControllerDidTapClose(_ controller: TextInputViewController) {
        hideTextInput()
    }
}
