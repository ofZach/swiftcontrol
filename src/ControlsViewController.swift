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
UICollectionViewDelegateFlowLayout {

    let kCellReuseIdentifier = String(describing: ImageCollectionViewCell.self);
    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var brushCollectionView: UICollectionView!

    let images = ["charlock",
                  "cleaver",
                  "maize",
                  "shepards purse",
                  "fat hen",
                  "sugar beet",
                  "maize",
                  "shepards purse"]

    var app: ofAppAdapter?

    override func viewDidLoad() {
        super.viewDidLoad();

        setUpCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    func setUpCollectionView() {
        brushCollectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: kCellReuseIdentifier)
    }

    @IBAction func didTapOpenDrawer() {
        UIView.animate(withDuration: 0.2)  {
            if (self.collectionViewBottomConstraint.constant < 0) {
                self.collectionViewBottomConstraint.constant = 0;
            } else {
                self.collectionViewBottomConstraint.constant = -200;
            }
            self.view.layoutIfNeeded()
        }
    }

    // text

    // textset(string)

    @IBAction func didTapTestText() {
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.width = size.height
        return size
    }

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
        if offset.x > scrollView.contentSize.width / 2 {
            scrollView.contentOffset = CGPoint(x: 0, y: offset.y)
        }
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        app?.setMode(Int32(indexPath.item))
    }

}
