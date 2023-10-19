import UIKit

final class ConsoleTextView: UITextView {
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextView() {
        isScrollEnabled = true
        isEditable = false
        backgroundColor = .tertiarySystemBackground
        textColor = .label
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    /// Update the text of the UITextView with the provided attributed string and scroll to the end.
    ///
    /// - Parameters:
    ///   - attributedString: The attributed string to set as the text of the UITextView.
    ///
    /// This method sets the `attributedText` property of the UITextView with the provided `attributedString` and ensures that the text view scrolls to the end, making the latest content visible.
    ///
    /// Example usage:
    /// ```
    /// let attributedString = NSAttributedString(string: "Hello, World!")
    /// myTextView.updateText(with: attributedString)
    /// ```
    ///
    /// - Note: If you wish to append text to the existing content, consider using `NSMutableAttributedString` and `append(_:)` instead.
    ///
    /// - Parameter attributedString: The attributed string to set as the text.
    func updateText(with attributedString: AttributedString) {
        attributedText = NSAttributedString(attributedString)
        scrollRangeToVisible(NSMakeRange(text.count, 0))
    }
}
