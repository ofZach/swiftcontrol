//
//  BrushSelectionViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 2/13/18.
//

import UIKit

private let kPaddingTopBottom: CGFloat = 50
private let kInterItemSpacing: CGFloat = 50
private let kLargeScrollViewMultiplier: CGFloat = 100 // no meaning, just meant to make scroll view large
private let kCellReuseIdentifier = String(describing: ImageCollectionViewCell.self);

protocol BrushSelectionViewControllerDelegate {
    func brushSelectionViewControllerDidSelectBrush(_ controller: BrushSelectionViewController,
                                                    at index: Int)
    func brushSelectionViewControllerDidTapClose(_ controller: BrushSelectionViewController)
}

class BrushSelectionViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var proxyScrollView: UIScrollView!
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var brushLabel: UILabel!
    private var lastScrollOffset: CGPoint?
    private var displayLink: CADisplayLink?
    var delegate: BrushSelectionViewControllerDelegate?
    let app: ofAppAdapter?
    let brushes: [Brush]

    private var indexPathInTheMiddle: IndexPath {
        let centerOffset = collectionView.contentOffset.x + collectionView.frame.width/2
        let index = Int(centerOffset/itemWidthWithPadding)
        return IndexPath(item: index, section: 0)
    }

    private var itemSize: CGSize {
        let edge = collectionView.frame.height - kPaddingTopBottom
        return CGSize(width: edge, height: edge)
    }

    private var itemWidthWithPadding: CGFloat {
        return itemSize.width + kInterItemSpacing
    }

    private var selectedIndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            app?.setMode(Int32(safeSelectedIndex))
        }
    }

    private var safeSelectedIndex: Int {
        return selectedIndexPath.item % brushes.count
    }

    required init(withApp app: ofAppAdapter, brushes: [Brush]) {
        self.app = app
        self.brushes = brushes
        super.init(nibName: String(describing: BrushSelectionViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpTapGestureRecognizer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData() // recalculate paddings when frames change
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetProxyScrollView()
    }

    private func setUpCollectionView() {
        collectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView.allowsMultipleSelection = false
    }

    private func setUpTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(gesture:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc func tappedView(gesture: UITapGestureRecognizer) {
        delegate?.brushSelectionViewControllerDidTapClose(self)
    }

    @IBAction func didTapNext() {
        selectItem(at: IndexPath(item: indexPathInTheMiddle.item + 1, section: 0),
                   animated: true)
    }

    @IBAction func didTapPrevious() {
        selectItem(at: IndexPath(item: indexPathInTheMiddle.item - 1, section: 0),
                   animated: true)
    }

    private func resetProxyScrollView() {
        backgroundView.addGestureRecognizer(proxyScrollView.panGestureRecognizer)
        proxyScrollView.contentSize = CGSize(width: view.frame.width * kLargeScrollViewMultiplier,
                                             height: view.frame.height)
        proxyScrollView.contentOffset = CGPoint(x: proxyScrollView.contentSize.width/2, y: 0)
        lastScrollOffset = proxyScrollView.contentOffset
        selectItem(at: selectedIndexPath, animated: false)
    }

    private func updateBrushLabelText() {
        print("safe: \(safeSelectedIndex)")
        brushLabel.text = brushes[safeSelectedIndex].imageName
    }
}

// MARK: display link handling
extension BrushSelectionViewController {
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
}

// MARK: UICollectionViewDelegateFlowLayout
extension BrushSelectionViewController : UICollectionViewDelegateFlowLayout {

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
}

// MARK: UICollectionViewDelegate
extension BrushSelectionViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        selectItem(at: indexPath, animated: true)

        let delay = indexPathInTheMiddle == indexPath ? 0.0 : 0.3
        // delay a closing a little bit so it's not so jarring
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.delegate?.brushSelectionViewControllerDidSelectBrush(self,
                                                                      at: self.selectedIndexPath.item % self.brushes.count)
        }
    }

    // we can't use UICollectionView.scrollToItem because it doesn't allow us to scroll to
    // negative content offsets
    private func selectItem(at indexPath: IndexPath, animated: Bool) {
        if let x = collectionView.layoutAttributesForItem(at: indexPath)?.center.x {
            let offset = x - collectionView.frame.width/2
            collectionView.setContentOffset(CGPoint(x:offset , y: 0), animated: animated)
        }
        selectedIndexPath = indexPath
        collectionView.reloadData()
        updateBrushLabelText()
    }
}

// MARK: UIScrollViewDelegate
extension BrushSelectionViewController : UIScrollViewDelegate {

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
        } else if scrollView == collectionView {
            // wrapping logic
            resetCollectionViewOffsetIfNecessary()
        }
    }

    func updateScrollViewOffset() {
        let lastScrollOffset = self.lastScrollOffset ?? proxyScrollView.contentOffset
        let offset = (proxyScrollView.contentOffset - lastScrollOffset)/proxyScrollView.frame.width
        let offsetForCollectionView = offset * itemWidthWithPadding
        collectionView.contentOffset += offsetForCollectionView
        self.lastScrollOffset = proxyScrollView.contentOffset
    }

    func resetCollectionViewOffsetIfNecessary() {
        let offset = collectionView.contentOffset
        let width = collectionView.contentSize.width / 2

        guard width > 0 else { return }
        let pos = offset.x.truncatingRemainder(dividingBy: width)
        if offset.x > width {
            collectionView.contentOffset = CGPoint(x: pos + kInterItemSpacing/2, y: offset.y)
        } else if (offset.x < 0) {
            collectionView.contentOffset = CGPoint(x: width + pos - kInterItemSpacing/2, y: offset.y)
        }
    }
}

// MARK: UICollectionViewDataSource
extension BrushSelectionViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return brushes.count * 2
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
        let index = indexPath.item % brushes.count
        cell.imageView.image = UIImage(named: brushes[index].imageName)
        if selectedIndexPath.item % brushes.count == index || selectedIndexPath.item == index {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        return cell
    }
}

// MARK: UIGestureRecognizerDelegate
extension BrushSelectionViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: view)
        guard let receivedView = view.hitTest(location, with: nil) else { return false }
        return receivedView == backgroundView.contentView
    }
}


