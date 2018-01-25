//
//  ImageCollectionViewCell.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

import Foundation
import UIKit

class ImageCollectionViewCell : UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .red : nil
        }
    }
}
