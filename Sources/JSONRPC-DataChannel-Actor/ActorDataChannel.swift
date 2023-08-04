import JSONRPC
import Foundation
import Collections

public actor DataActor {
  var queue: Deque<Data>
  var continuation: CheckedContinuation<Data, Never>?
  private(set) var numSent: Int
  public var numReceived: Int { numSent - queue.count }
  private(set) var numBlocking: Int
  public var queueCount: Int { queue.count }

  public func send(_ data: Data) -> Void {
    numSent += 1
    if let c = continuation {
      assert(queue.isEmpty)
      continuation = nil
      c.resume(returning: data)
    }
    else {
      queue.append(data)
    }
  }

  public func recv() async -> Data {
    if let data = queue.popFirst() {
      return data
    }

    numBlocking += 1

    return await withCheckedContinuation {
      continuation = $0
    }
  }

  public init(minimumCapacity: Int = 32) {
    queue = Deque(minimumCapacity: minimumCapacity)
    // queue = []
    numSent = 0
    numBlocking = 0
  }
}

extension DataChannel {

  public init(dataActor: DataActor) {
    let writeHandler = { @Sendable data in
      await dataActor.send(data)
    }

    let dataSequence = DataSequence {
        await dataActor.recv()
        // do {
        //   let d = try await dataActor.recv()
        //   return d
        // } catch {
        //   print("DataChannel socket error: \(error)")
        //   return nil
        // }

    } onCancel: { @Sendable () in print("Canceled.") }


    self.init(writeHandler: writeHandler, dataSequence: dataSequence)
  }
}
