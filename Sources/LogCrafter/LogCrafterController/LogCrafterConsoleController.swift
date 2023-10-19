import UIKit
import Combine

class LogCrafterConsoleController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: LogCrafterControllerViewModelInterface
    private var disposableBag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: LogCrafterControllerViewModelInterface = LogCrafterControllerViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addKeyboardObservers()
        subscribeToViewModel()
    }
    
    // MARK: - Actions
    
    /// Clears the log messages in the consoleTextView.
    @objc func clearLogAction() {
        viewModel.clearLog()
    }
    
    /// Handles text field editing changes and initiates a search based on the entered text.
    @objc func textFieldEditingChanged(sender: UITextField) {
        viewModel.search(for: sender.text ?? "")
    }
    
    /// Copies the log messages to the clipboard.
    @objc func copyLogAction() {
        viewModel.copyLog()
    }
    
    // MARK: - Private work
    
    /// Subscribe to the view model's log text updates and display them in the consoleTextView.
    ///
    /// This method sets up a subscription to the `logTextPublisher` provided by the view model. It listens for log message updates, received on the main thread, and updates the content of the `consoleTextView` with the provided attributed string.
    ///
    /// - Note: The method uses a Combine `sink` operator to handle updates from the view model's `CurrentValueSubject` publisher. It automatically manages the subscription's lifetime through the `disposableBag`.
    private func subscribeToViewModel() {
        viewModel.logTextPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (logMessage: AttributedString) in
                guard let self else { return }
                consoleTextView.updateText(with: logMessage)
            }
            .store(in: &disposableBag)
    }


    //MARK: - UI Elements
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search in console"
        textField.clearButtonMode = .whileEditing
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.addTarget(self, action: #selector(textFieldEditingChanged(sender:)), for: .editingChanged)
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var consoleTrackrButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Clear"
        configuration.baseBackgroundColor = .red
        button.role = .destructive
        button.configuration = configuration
        button.addTarget(self, action: #selector(clearLogAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Copy Log"
        button.configuration = configuration
        button.addTarget(self, action: #selector(copyLogAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var consoleTextView: ConsoleTextView = {
        let textView = ConsoleTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
}

// MARK: - UI Setup

private extension LogCrafterConsoleController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainStackView)
        view.addSubview(consoleTextView)
        buttonsStack.addArrangedSubview(consoleTrackrButton)
        buttonsStack.addArrangedSubview(copyButton)
        mainStackView.addArrangedSubview(buttonsStack)
        mainStackView.addArrangedSubview(searchTextField)
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: 16),
            
            consoleTextView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 16),
            consoleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: consoleTextView.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(equalTo: consoleTextView.bottomAnchor, constant: 32)
        ])
    }
}

// MARK: - Keyboard Observer

extension LogCrafterConsoleController {
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardDidChange(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardMinY = keyboardValue.cgRectValue.minY
        if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
            consoleTextView.scrollRangeToVisible(NSMakeRange(consoleTextView.text.count, 0))
            return
        }
        
        let activeTextFieldMaxYOnScreen = searchTextField.frame.maxY
        
        if keyboardMinY < activeTextFieldMaxYOnScreen {
            
            self.view.frame.origin.y -= ((activeTextFieldMaxYOnScreen + 8) - keyboardMinY)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LogCrafterConsoleController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

