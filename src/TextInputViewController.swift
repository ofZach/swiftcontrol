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

let quotes = [
    "Go ahead and make my day",
    "Hello Lovely",
    "Stay Weird"
]

class TextInputViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var characterCountLabel: UILabel!
    @IBOutlet var textViewCancel: UIButton!

    private let maxCharacters = 30
    private var availableCharacters: Int {
        return maxCharacters - textView.text.count
    }

    private var currentString: String? {
        didSet {
            let currentString = self.currentString ?? ""
            app?.setText(currentString)
        }
    }
    var app: ofAppAdapter?
    var delegate: TextInputViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTextViewText()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTextViewText()
        textView.becomeFirstResponder()
    }

    private func updateTextViewText() {
        textView.text = currentString
        updateLabelCount()
    }


    @IBAction func didTapCloseText() {
        hideTextView()
    }

    @IBAction func didRequestRandomWord() {
        while true {
            let safeIndex = Int(arc4random()) % quotes.count
            if quotes[safeIndex] != currentString {
                currentString = quotes[safeIndex]
                updateTextViewText()
                break
            }
        }
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
            currentString = textView.text
            hideTextView()
            return false
        } else if availableCharacters == 0 {
            flashLabelReachedMaxCharacters()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        updateLabelCount()
    }

    private func updateLabelCount() {
        characterCountLabel.text = "\(availableCharacters)"
    }

    private func flashLabelReachedMaxCharacters() {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
            self.characterCountLabel.transform = self.characterCountLabel.transform
                .concatenating(CGAffineTransform(scaleX: 1.3, y: 1.3))
        }
        animator.addCompletion { _ in
            let secondAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
                self.characterCountLabel.transform = .identity
            }
            secondAnimator.startAnimation()
        }
        animator.startAnimation()
    }
}
