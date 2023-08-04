import XCTest
@testable import JSONRPC_DataChannel_Actor

// XCTest Documenation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
final class JSONRPC_DataChannel_ActorTests: XCTestCase {
  func testEmptyChannelBlocking() async throws {
    let channel = DataActor()

    let receiveTask = Task {
      let receivedData = await channel.recv()
      return String(data: receivedData, encoding: .utf8)!
    }
    let msg = "hello"
    await channel.send(msg.data(using: .utf8)!)
    let receivedMsg = await receiveTask.result
    XCTAssertEqual(msg, try receivedMsg.get())

    await channel.send(msg.data(using: .utf8)!)

    let numSent = await channel.numSent
    let numReceived = await channel.numReceived
    let numBlocking = await channel.numBlocking
    let queueCount = await channel.queueCount

    XCTAssertEqual(numSent, 2)
    XCTAssertEqual(numReceived, 1)
    XCTAssertEqual(numBlocking, 1)
    XCTAssertEqual(queueCount, 1)
  }
}
