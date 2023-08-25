import XCTest
import JSONRPC
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

    // try await Task.sleep(for: Duration.seconds(0.05))
    while await channel.numBlocking == 0 {
      continue
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

  func testBidirectionalChannel() async throws {
    let (clientChannel, serverChannel) = DataChannel.withDataActor()
    let msg = "hello"
    try await clientChannel.writeHandler(msg.data(using: .utf8)!)
    var it = serverChannel.dataSequence.makeAsyncIterator();
    let receivedData = await it.next()
    let receivedMsg = String(data: receivedData!, encoding: .utf8)!
    XCTAssertEqual(msg, receivedMsg)

  }

  func testSimpleRPC() {
    let (_, serverChannel) = DataChannel.withDataActor()
    let _ = JSONRPCSession(channel: serverChannel)
    // TODO...
  }
}
