import JSONRPC
import Foundation
import Collections

public actor DataActor {
  var queue: Deque<Data>
  var continuation: CheckedContinuation<Data, Never>?
  private(set) var numSent: Int
  public var numReceived: Int { numSent - queue.count }
  private(set) var numBlocked: Int
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

    numBlocked += 1

    return await withCheckedContinuation {
      continuation = $0
    }
  }

  public init(minimumCapacity: Int = 32) {
    queue = Deque(minimumCapacity: minimumCapacity)
    numSent = 0
    numBlocked = 0
  }
}

extension DataChannel {

  // NOTE: The actor data channel conist of two directional actor data channels with crossover send/receive members
  public static func withDataActor(minimumCapacity: Int = 32) -> (clientChannel: DataChannel, serverChannel: DataChannel) {
    let clientActor = DataActor(minimumCapacity: minimumCapacity)
    let serverActor = DataActor(minimumCapacity: minimumCapacity)

    let clientChannel = makeChannel(sender: clientActor, reciever: serverActor)
    let serverChannel = makeChannel(sender: serverActor, reciever: clientActor)

    return (clientChannel, serverChannel)
  }

  private static func makeChannel(sender: DataActor, reciever: DataActor, onCancel: (@Sendable () -> Void)? = nil) -> DataChannel {
    let writeHandler = { @Sendable data in
      await sender.send(data)
    }

    let dataSequence = DataChannel.DataSequence {
        await reciever.recv()
    } onCancel: { onCancel?() }


    return DataChannel(writeHandler: writeHandler, dataSequence: dataSequence)
  }
}
