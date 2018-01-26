//
//  AboutViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 1/26/18.
//

import UIKit

protocol AboutViewControllerDelegate: NSObjectProtocol {

    func aboutViewControllerDidTapClose(_ controller: AboutViewController)

}

class AboutViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!

    weak var delegate: AboutViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAboutPages()
    }

    @IBAction func didTapCloseButton() {
        delegate?.aboutViewControllerDidTapClose(self)
    }

    private func loadAboutPages() {
        let nib = UINib(nibName: "AboutViews", bundle:nil)
        if let views = nib.instantiate(withOwner: self, options: nil) as? [UIView] {
            pageControl.numberOfPages = views.count
            for i in 0..<views.count {
                let cur = views[i]
                scrollView.addSubview(cur)
                if i == 0 {
                    cur.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
                } else {
                    cur.autoPinEdge(toSuperviewEdge: .top)
                    cur.autoPinEdge(toSuperviewEdge: .bottom)
                    cur.autoPinEdge(.leading, to: .trailing, of: views[i-1])

                    if i == views.count - 1 {
                        cur.autoPinEdge(toSuperviewEdge: .trailing)
                    }
                }

                cur.autoMatch(.width, to: .width, of: scrollView)
                cur.autoMatch(.height, to: .height, of: scrollView)

            }

        }
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = index
    }

}
