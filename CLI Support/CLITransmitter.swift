//
//  CLITransmitter.swift
//  listrctl
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import ArgumentParser
import MultipeerKit

final class CLITransmitter {

    static let current = CLITransmitter()

    static let serviceType = "listrctl"

    private lazy var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default

        config.serviceType = Self.serviceType

        return MultipeerTransceiver(configuration: config)
    }()

    var outputPath: String!

    func start() {
        transceiver.receive(CLIResponse.self) { [weak self] command in
            guard let self = self else { return }

            switch command {
            case .message(let message):
                print(message)
            case .data(let data):
                self.handleDataReceived(data)
            }

            exit(0)
        }

        transceiver.resume()
    }

    private func handleDataReceived(_ data: Data) {
        try! data.write(to: URL(fileURLWithPath: outputPath))
        outputPath = nil
    }

    private let queue = DispatchQueue(label: "CLITransmitter")

    private func requirementsMet(with peers: [Peer]) -> Bool {
        !peers.filter({ $0.isConnected }).isEmpty
    }

    func send<T: Encodable>(_ command: T) {
        queue.async {
            let sema = DispatchSemaphore(value: 0)

            self.transceiver.availablePeersDidChange = { peers in
                guard self.requirementsMet(with: peers) else { return }

                sema.signal()
            }

            _ = sema.wait(timeout: .now() + 20)

            DispatchQueue.main.async {
                self.transceiver.broadcast(command)
            }
        }

        CFRunLoopRun()
    }

}

extension ParsableCommand {
    func send<T: Encodable>(_ command: T) {
        CLITransmitter.current.send(command)
    }
}
