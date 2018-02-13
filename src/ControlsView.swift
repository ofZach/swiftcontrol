//
//  ControlsView.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 2/13/18.
//

import UIKit

protocol ControlViewDelegate: NSObjectProtocol {
    func shouldHandleTouch(_ controlView: ControlView) -> Bool
    func handleTouch(_ controlView: ControlView)
}

class ControlView: UIView {
    weak var delegate: ControlViewDelegate?

    var touch: UITouch?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let controller = delegate else { return }
        controller.handleTouch(self)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        guard let controller = delegate else { return view }

        if self == view {
            if controller.shouldHandleTouch(self) {
                return view
            }
        } else if view.isDescendant(of: self) {
            return view
        }
        return nil
    }
}

