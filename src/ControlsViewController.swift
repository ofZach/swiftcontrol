//
//  ControlsViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

import Foundation
import UIKit

private let kPaddingTopBottom: CGFloat = 50
private let kInterItemSpacing: CGFloat = 50
private let kLargeScrollViewMultiplier: CGFloat = 100 // no meaning, just meant to make scroll view large

class ControlsViewController : UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UITextViewDelegate,
AboutViewControllerDelegate {

    private let kCellReuseIdentifier = String(describing: ImageCollectionViewCell.self);

    @IBOutlet var collectionViewYConstraint: NSLayoutConstraint!
    @IBOutlet var brushCollectionView: UICollectionView!
    @IBOutlet var proxyScrollView: UIScrollView!
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewCancel: UIButton!
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

    private var lastScrollOffset: CGPoint?
    private var currentString: String?
    private var displayLink: CADisplayLink?

    private var itemSize: CGSize {
        let edge = brushCollectionView.frame.height - kPaddingTopBottom
        return CGSize(width: edge, height: edge)
    }

    private var isDrawerOpen: Bool {
        return brushCollectionView.alpha > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextView()
        setUpCollectionView()
        hideDrawer(animated: false)

        if let controlView = view as? ControlView {
            controlView.controller = self
        }
    }

    private func resetProxyScrollView() {
        backgroundView.addGestureRecognizer(proxyScrollView.panGestureRecognizer)
        proxyScrollView.contentSize = CGSize(width: view.frame.width * kLargeScrollViewMultiplier,
                                             height: view.frame.height)
        proxyScrollView.contentOffset = CGPoint(x: proxyScrollView.contentSize.width/2, y: 0)
        lastScrollOffset = proxyScrollView.contentOffset

        // select an index if one has not been selected yet. This always assumes we start with the
        // first index. We select index 0 + n as opposed to 0 so that items will be visible on
        // both left and right sies.
        let selectedIndex = brushCollectionView.indexPathsForSelectedItems?.first ?? IndexPath(item: images.count, section: 0)
        brushCollectionView.selectItem(at: selectedIndex,
                                       animated: false,
                                       scrollPosition: .centeredHorizontally)
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

    private func hideDrawer(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: {
                        self.backgroundView.alpha = 0
                        self.collectionViewYConstraint.constant = 50
                        self.view.layoutIfNeeded()
        }, completion: { finished in
            self.brushCollectionView.alpha = 0
        })
    }

    @objc func showDrawer() {
        resetProxyScrollView()
        // make sure other controls on the background view are hidden
        textView.alpha = 0
        textViewCancel.alpha = 0
        UIView.animate(withDuration: 0.3)  {
            self.backgroundView.alpha = 1.0
            self.brushCollectionView.alpha = 1.0
            self.collectionViewYConstraint.constant = 0
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
        textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3)  {
            self.textBackgroundView.alpha = 0.0
        }

    }
    private func showTextView() {
        UIView.animate(withDuration: 0.3)  {
            self.textBackgroundView.alpha = 1.0
        }
    }

    private func startDisplayLink() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(runDisplayLink))
        displayLink?.add(to: .main, forMode: .UITrackingRunLoopMode)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func runDisplayLink() {
        app?.tick()
    }

    @IBAction func didTapTestText() {
        textView.text = currentString
        hideDrawer()
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

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
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
        let safeIndex = indexPath.item % images.count
        app?.setMode(Int32(safeIndex))

        // delay a closing a little bit so it's not so jarring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideDrawer()
        }

    }

    // MARK: UIScrollView

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDisplayLink()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stopDisplayLink()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stopDisplayLink()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == proxyScrollView {
            // paging logic
            let lastScrollOffset = self.lastScrollOffset ?? scrollView.contentOffset
            let offset = (scrollView.contentOffset - lastScrollOffset)/scrollView.frame.width
            let itemSizeWithPadding = itemSize.width + kInterItemSpacing
            let offsetForCollectionView = offset * itemSizeWithPadding
            brushCollectionView.contentOffset += offsetForCollectionView
            self.lastScrollOffset = scrollView.contentOffset
        } else if scrollView == brushCollectionView {
            // wrapping logic
            let offset = scrollView.contentOffset
            let width = scrollView.contentSize.width / 2
            let pos = offset.x.truncatingRemainder(dividingBy: width)
            if offset.x > width {
                scrollView.contentOffset = CGPoint(x: pos + kInterItemSpacing/2, y: offset.y)
            } else if (offset.x < 0) {
                scrollView.contentOffset = CGPoint(x: width + pos - kInterItemSpacing/2, y: offset.y)
            }
        }
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

        if self == view && controller.shouldHandleTouch()  {
            return view
        } else if view.isDescendant(of: self) {
            return view
        } else {
            return nil
        }
    }
}
