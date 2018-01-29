//
//  ControlsViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

import Foundation
import UIKit

class ControlsViewController : UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UITextViewDelegate,
AboutViewControllerDelegate {

    private let kPaddingTopBottom: CGFloat = 50
    private let kInterItemSpacing: CGFloat = 50

    private let kCellReuseIdentifier = String(describing: ImageCollectionViewCell.self);

    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var brushCollectionView: UICollectionView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textBackgroundView: UIView!

    private var aboutViewController: AboutViewController?

    let images = ["charlock",
                  "cleaver",
                  "maize",
                  "shepards purse",
                  "fat hen",
                  "sugar beet",
                  "maize",
                  "shepards purse"]

    @objc var app: ofAppAdapter?

    private var currentString: String?

    private var isDrawerOpen: Bool {
        return collectionViewBottomConstraint.constant >= 0
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        setUpTextView()
        setUpCollectionView()

        if let controlView = view as? ControlView {
            controlView.controller = self
        }
    }

    private func setUpTextView() {
        hideTextView()
    }

    private func setUpCollectionView() {
        brushCollectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: kCellReuseIdentifier)
        brushCollectionView.allowsMultipleSelection = false
    }

    @IBAction func didTapOpenDrawer() {
        if (isDrawerOpen) {
            hideDrawer()
        } else {
            showDrawer()
        }
    }

    private func hideDrawer() {
        UIView.animate(withDuration: 0.3)  {
            self.collectionViewBottomConstraint.constant = -self.brushCollectionView.frame.height
            self.view.layoutIfNeeded()
        }
    }

    @objc func showDrawer() {
        UIView.animate(withDuration: 0.3)  {
            self.collectionViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
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

    private func hideTextView() {
        UIView.animate(withDuration: 0.3)  {
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
        hideDrawer()
        showTextView()
        textView.becomeFirstResponder()
    }

    @IBAction func didTapCloseText() {
        textView.resignFirstResponder()
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

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height -= kPaddingTopBottom
        size.width = size.height
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kInterItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = floor(kPaddingTopBottom/2)
        return UIEdgeInsetsMake(padding, kInterItemSpacing, padding, kInterItemSpacing)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return images.count * 2
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // workaround - because we select items at selectedIndex and selectedIndex * 2, we need
        // to clear it out.
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:kCellReuseIdentifier,
                                                            for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        let index = indexPath.item % images.count
        cell.imageView.image = UIImage(named: images[index])
        if let selected = collectionView.indexPathsForSelectedItems?.first {
            if selected.item % images.count == index {
                cell.isSelected = true
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item % images.count
        app?.setMode(Int32(index))

        // delay a closing a little bit so it's not so jarring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.hideDrawer()
        }

    }

    // MARK: UIScrollView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let width = scrollView.contentSize.width / 2
        let pos = offset.x.truncatingRemainder(dividingBy: width)
        if offset.x > width {
            scrollView.contentOffset = CGPoint(x: pos + kInterItemSpacing/2, y: offset.y)
        } else if (offset.x < 0) {
            scrollView.contentOffset = CGPoint(x: width + pos - kInterItemSpacing/2, y: offset.y)
        }
    }

    // MARK: ControlView handling
    func shouldHandleTouch() -> Bool {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
            return true
        } else if isDrawerOpen {
            hideDrawer()
            return true
        }
        return false
    }
}

class ControlView: UIView {
    weak var controller: ControlsViewController?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if self == view  {
            if controller?.shouldHandleTouch() ?? false {
                return view
            } else {
                return nil
            }
        }
        return view
    }
}
