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
UITextViewDelegate {

    let kPaddingTopBottom: CGFloat = 50
    let kInterItemSpacing: CGFloat = 50

    let kCellReuseIdentifier = String(describing: ImageCollectionViewCell.self);

    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var brushCollectionView: UICollectionView!
    @IBOutlet var textView: UITextView!

    let images = ["charlock",
                  "cleaver",
                  "maize",
                  "shepards purse"]
//                  "fat hen",
//                  "sugar beet",
//                  "maize",
//                  "shepards purse"]

    var app: ofAppAdapter?

    override func viewDidLoad() {
        super.viewDidLoad();
        setUpTextView()
        setUpCollectionView()

        if let controlView = view as? ControlView {
            controlView.controller = self
        }
    }

    func setUpTextView() {
        textView.alpha = 0.0
    }

    func setUpCollectionView() {
        brushCollectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: kCellReuseIdentifier)

    }

    @IBAction func didTapOpenDrawer() {
        UIView.animate(withDuration: 0.2)  {
            if (self.collectionViewBottomConstraint.constant < 0) {
                self.showDrawer()
            } else {
                self.hideDrawer()
            }
            self.view.layoutIfNeeded()
        }
    }

    func hideDrawer() {
        collectionViewBottomConstraint.constant = -200
    }

    func showDrawer() {
        collectionViewBottomConstraint.constant = 0
    }

    func hideTextView() {
        textView.alpha = 0
    }
    func showTextView() {
        textView.alpha = 1
    }



    @IBAction func didTapTestText() {
        UIView.animate(withDuration: 0.2)  {
            self.textView.alpha  = 1.0;
            self.textView.becomeFirstResponder()
            self.hideDrawer()
        }
    }

    // MARK: UITextViewDelegate

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            app?.setText(textView.text)
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
        return UIEdgeInsetsMake(0, kInterItemSpacing, 0, kInterItemSpacing)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return images.count * 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:kCellReuseIdentifier,
                                                            for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        let index = indexPath.item % images.count
        cell.imageView.image = UIImage(named: images[index])
        return cell
    }

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

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        app?.setMode(Int32(indexPath.item))
    }

    // MARK: ControlView handling
    func shouldHandleTouch() -> Bool {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
            return true
        }
        return false
    }
}


class ControlView: UIView {
    weak var controller: ControlsViewController?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if self == view && controller?.shouldHandleTouch() ?? false {
            return nil
        }
        return view
    }
}
