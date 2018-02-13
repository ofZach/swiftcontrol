//
//  TextInputViewController.swift
//  zach-controls
//
//  Created by Ying Quan Tan on 2/13/18.
//

import UIKit

protocol TextInputViewControllerDelegate {
    func textInputViewControllerDidTapClose(_ controller: TextInputViewController)
}

class TextInputViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewCancel: UIButton!

    private var currentString: String?
    var app: ofAppAdapter?
    var delegate: TextInputViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = currentString
        textView.becomeFirstResponder()
    }

    @IBAction func didTapCloseText() {
        hideTextView()
    }

    private func hideTextView() {
        delegate?.textInputViewControllerDidTapClose(self)
    }
}

extension TextInputViewController : UITextViewDelegate {
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
}
