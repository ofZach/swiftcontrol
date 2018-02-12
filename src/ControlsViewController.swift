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

    @IBOutlet var brushCollectionView: UICollectionView!
    @IBOutlet var proxyScrollView: UIScrollView!
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewCancel: UIButton!
    @IBOutlet var textBackgroundView: UIView!
    @IBOutlet var brushLabel: UILabel!

    private var aboutViewController: AboutViewController?

    let images = [Brush(name: "Charlock", imageName: "charlock"),
                  Brush(name: "Cleaver", imageName: "cleaver"),
                  Brush(name: "Maize", imageName: "maize"),
                  Brush(name: "Shepards purse", imageName: "shepards purse"),
                  Brush(name: "Fat Hen", imageName: "fat hen"),
                  Brush(name: "Sugar Beet", imageName: "sugar beet"),
                  Brush(name: "Maize", imageName: "maize")]

    @objc var app: ofAppAdapter?

    private var lastScrollOffset: CGPoint?
    private var currentString: String?
    private var displayLink: CADisplayLink?

    private var selectedIndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            let safeIndex = selectedIndexPath.item % images.count
            app?.setMode(Int32(safeIndex))
        }
    }

    private var indexPathInTheMiddle: IndexPath {
        let centerOffset = brushCollectionView.contentOffset.x + brushCollectionView.frame.width/2
        let index = Int(centerOffset/itemWidthWithPadding)
        return IndexPath(item: index, section: 0)
    }

    private var itemSize: CGSize {
        let edge = brushCollectionView.frame.height - kPaddingTopBottom
        return CGSize(width: edge, height: edge)
    }

    private var itemWidthWithPadding: CGFloat {
        return itemSize.width + kInterItemSpacing
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        brushCollectionView.reloadData() // recalculate paddings when frames change
    }

    private func resetProxyScrollView() {
        backgroundView.addGestureRecognizer(proxyScrollView.panGestureRecognizer)
        proxyScrollView.contentSize = CGSize(width: view.frame.width * kLargeScrollViewMultiplier,
                                             height: view.frame.height)
        proxyScrollView.contentOffset = CGPoint(x: proxyScrollView.contentSize.width/2, y: 0)
        lastScrollOffset = proxyScrollView.contentOffset
        selectItem(at: selectedIndexPath, animated: false)
    }

    private func setUpTextView() {
        hideTextView(animated: false)
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

    @IBAction func didTapNext() {
        selectItem(at: IndexPath(item: indexPathInTheMiddle.item + 1, section: 0),
                     animated: true)
    }

    @IBAction func didTapPrevious() {
        selectItem(at: IndexPath(item: indexPathInTheMiddle.item - 1, section: 0),
                     animated: true)
    }

    private func hideDrawer(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: {
                        self.backgroundView.alpha = 0
        }, completion: { finished in
            self.brushCollectionView.alpha = 0
        })
    }

    @objc func showDrawer() {
        resetProxyScrollView()
        UIView.animate(withDuration: 0.3)  {
            self.backgroundView.alpha = 1.0
            self.brushCollectionView.alpha = 1.0
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
        cell.imageView.image = UIImage(named: images[index].imageName)
        if selectedIndexPath.item % images.count == index || selectedIndexPath.item == index {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        selectItem(at: indexPath, animated: true)

        // delay a closing a little bit so it's not so jarring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.hideDrawer()
        }
    }

    // we can't use UICollectionView.scrollToItem because it doesn't allow us to scroll to
    // negative content offsets
    private func selectItem(at indexPath: IndexPath, animated: Bool) {
        if let x = brushCollectionView.layoutAttributesForItem(at: indexPath)?.center.x {
            let offset = x - brushCollectionView.frame.width/2
            brushCollectionView.setContentOffset(CGPoint(x:offset , y: 0), animated: animated)
        }
        selectedIndexPath = indexPath
        brushCollectionView.reloadData()
    }

    // MARK: UIScrollView

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDisplayLink()
        UIView.animate(withDuration: 0.2) {
            self.brushLabel.alpha = 0.0
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stopDisplayLink()

        // select the item in the middle of the screen
        selectItem(at: indexPathInTheMiddle, animated: false)

        UIView.animate(withDuration: 0.2) {
            self.brushLabel.alpha = 1.0
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stopDisplayLink()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == proxyScrollView {
            // paging logic
            updateScrollViewOffset()
        } else if scrollView == brushCollectionView {
            // wrapping logic
            resetCollectionViewOffsetIfNecessary()
            updateBrushLabelText()
        }
    }

    func updateScrollViewOffset() {
        let lastScrollOffset = self.lastScrollOffset ?? proxyScrollView.contentOffset
        let offset = (proxyScrollView.contentOffset - lastScrollOffset)/proxyScrollView.frame.width
        let offsetForCollectionView = offset * itemWidthWithPadding
        brushCollectionView.contentOffset += offsetForCollectionView
        self.lastScrollOffset = proxyScrollView.contentOffset
    }

    func resetCollectionViewOffsetIfNecessary() {
        let offset = brushCollectionView.contentOffset
        let width = brushCollectionView.contentSize.width / 2

        guard width > 0 else { return }
        let pos = offset.x.truncatingRemainder(dividingBy: width)
        if offset.x > width {
            brushCollectionView.contentOffset = CGPoint(x: pos + kInterItemSpacing/2, y: offset.y)
        } else if (offset.x < 0) {
            brushCollectionView.contentOffset = CGPoint(x: width + pos - kInterItemSpacing/2, y: offset.y)
        }
    }

    func updateBrushLabelText() {
        let safeIndex = indexPathInTheMiddle.item % images.count
        brushLabel.text = images[safeIndex].imageName
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
