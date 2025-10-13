//
//  Chunking.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 03.05.2025.
//

import Foundation

extension FixedWidthInteger {
    var bigEndianData: Data {
        var value = self.bigEndian
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
extension URLSessionWebSocketTask {
    
    /// - parameter maxChunkSize: The maximum size of a chunk. If nil, the entire object is sent in one chunk without any header.
    func send(_ value: some Encodable, maxChunkSize: Int?, encoder: JSONEncoder = JSONEncoder()) async throws {
        guard let maxChunkSize else {
            try await send(value, encoder: encoder)
            return
        }
        
        let encoded = try encoder.encode(value)
        
        let packetIdentifier = UInt32.random(in: 0...UInt32.max)
        
        func headerBytes(for offset: Int, totalChunks: Int) -> Data {
            // 4 byte each
            var header = Data(capacity: 12)
            header.append(packetIdentifier.bigEndianData)
            header.append(UInt32(offset).bigEndianData)
            header.append(UInt32(totalChunks).bigEndianData)
            return header
        }
        
        let totalChunks = (encoded.count + maxChunkSize - 1) / maxChunkSize
        for (chunkIndex, offset) in stride(from: 0, to: encoded.count, by: maxChunkSize).enumerated() {
            let end = min(offset + maxChunkSize, encoded.count)
            let slice = encoded[offset..<end]
            let header = headerBytes(for: chunkIndex, totalChunks: totalChunks)
            try await send(.data(header + slice))
        }
    }
    
}
