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
    // modeset(int)
    // images for the view
    //

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
        return 9
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:kCellReuseIdentifier,
                                                            for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {



    }

}
