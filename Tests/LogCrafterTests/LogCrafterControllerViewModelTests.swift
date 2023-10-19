import XCTest
import Combine
@testable import LogCrafter

final class LogCrafterControllerViewModelTests: XCTestCase {
    
    var sut: LogCrafterControllerViewModel!
    var disposableBag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = LogCrafterControllerViewModel()
        disposableBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut.clearLog()
        sut = nil
        disposableBag = nil
        super.tearDown()
    }
    
    func test_copyLogToPasteboard() {
        LCLog(.custom("TestType"), message: "Test message")
            
        sut.copyLog()
        
        guard let pasteboardString = UIPasteboard.general.string else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(pasteboardString.contains("][TestType] - Test message\n"))
    }
    
    func test_clearLog() {
        for i in 0...10 {
           LCLog(.info, message: "NewMessage at index \(i)")
        }
        
        sut.clearLog()
        
        XCTAssertTrue(String(sut.logTextPublisher.value.characters).isEmpty)
    }
    
    func test_searchLogMessage() {
        for i in 0..<20 {
           LCLog(.info, message: "NewMessage at index \(i)")
        }
        
        testSearch(query: "NewMessage at index 1", assertCount: 11)
        testSearch(query: "NewMessage at index 0", assertCount: 1)
        testSearch(query: "", assertCount: 20)
    }
    
    func test_applyAttribute() {
        let message = LCLog(.error, message: "Test message")
        let attributedString = sut.applyAttributes(to: message)
        let attributes = NSAttributedString(attributedString).attributes(at: 0, effectiveRange: nil)
        
        XCTAssertEqual(attributes[NSAttributedString.Key.foregroundColor] as! UIColor, .systemOrange)
    }
    
    func test_logTextPublisher() {
        let expectation = expectation(description: "Received when adding log message")
        LCLog(.info, message: "This is a message to test the publisher")
        
        sut.logTextPublisher
            .receive(on: RunLoop.main)
            .sink { message in
                expectation.fulfill()
                XCTAssertTrue(String(message.characters).contains("[INFO] - This is a message to test the publisher"))
            }
            .store(in: &disposableBag)
        
        wait(for: [expectation], timeout: 1)
    }
}

private extension LogCrafterControllerViewModelTests {
    
    func getLogMessagesAsString() -> [String] {
        String(sut.logTextPublisher.value.characters)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }
    
    func testSearch(query: String, assertCount: Int) {
        sut.search(for: query)
        XCTAssertEqual(getLogMessagesAsString().count, assertCount)
    }
}
