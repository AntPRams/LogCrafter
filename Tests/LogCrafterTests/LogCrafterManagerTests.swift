import XCTest
@testable import LogCrafter

final class LogCrafterManagerTests: XCTestCase {
    
    var sut = LogCrafterManager.shared
    var concurrentQueue: DispatchQueue!
    
    override func setUp() {
        super.setUp()
        
        concurrentQueue = DispatchQueue(label: "LogCrafterManagerTests.Queue", attributes: .concurrent)
    }
    
    override func tearDown() {
        concurrentQueue = nil
        super.tearDown()
    }
    
    func test_dataAccessorsConcurrency() {
        let expectation = expectation(description: "Using manager from multiple threads shall succeed")
        let callCount = 100
        
        for i in 0..<callCount {
            concurrentQueue.async {
                self.sut.appendLogMessage(LCLog(.info, message: "log at index \(i)"))
            }
        }
        
        for _ in 0..<callCount {
            _ = sut.getLogMessages()
        }
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 0.5)
        sut.clearLog()
        XCTAssertTrue(sut.getLogMessages().isEmpty)
    }
}
