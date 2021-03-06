//
//  PipelineResponseHandler.swift
//  snake-http
//
//  Created by panghu on 7/10/20.
//

import Foundation
import NIOCore
import NIOHTTP1

final class PipelineResponseHandler: ChannelOutboundHandler, RemovableChannelHandler {
    
    typealias OutboundIn = Message
    typealias OutboundOut = HTTPServerResponsePart
    
    let application: Application
    
    init(application: Application) {
        self.application = application
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let message = unwrapOutboundIn(data)
        let response = message.response
        let head = response.head
        
        context.write(wrapOutboundOut(.head(message.response.head)), promise: nil)
        write(context: context, head: head, body: message.response.body, response: response).whenComplete { [self] _ in
            context.writeAndFlush(wrapOutboundOut(.end(nil))).whenComplete { result in
                promise?.completeWith(result)
                context.close(promise: nil)
            }
        }
        puts(code: head.status.code, method: message.request.head.method.rawValue, uri: message.request.head.uri, from: context.remoteAddress)
    }
    
    private func write(context: ChannelHandlerContext, head: HTTPResponseHead, body: MessageBody, response: MessageResponse) -> EventLoopFuture<Void> {
        switch body.storage {
        case .empty:
            return write(context: context)
        case .buffer(let buffer):
            return write(context: context, buffer: buffer)
        case .data(let data):
            return write(context: context, data: data)
        case .string(let string):
            return write(context: context, string: string)
        case .json(let json):
            return write(context: context, json: json)
        case .stream(let stream):
            return write(context: context, stream: stream)
        }
    }
    
    private func write(context: ChannelHandlerContext) -> EventLoopFuture<Void> {
        return context.eventLoop.makeSucceededFuture(())
    }
    
    private func write(context: ChannelHandlerContext, buffer: ByteBuffer) -> EventLoopFuture<Void> {
        return context.writeAndFlush(wrapOutboundOut(.body(.byteBuffer(buffer))))
    }
    
    private func write(context: ChannelHandlerContext, data: Data) -> EventLoopFuture<Void> {
        var buffer = context.channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        return context.writeAndFlush(wrapOutboundOut(.body(.byteBuffer(buffer))))
    }
    
    private func write(context: ChannelHandlerContext, string: String) -> EventLoopFuture<Void> {
        var buffer = context.channel.allocator.buffer(capacity: string.count)
        buffer.writeString(string)
        return context.writeAndFlush(wrapOutboundOut(.body(.byteBuffer(buffer))))
    }
    
    private func write(context: ChannelHandlerContext, json: Any) -> EventLoopFuture<Void> {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            var buffer = context.channel.allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)
            return context.writeAndFlush(wrapOutboundOut(.body(.byteBuffer(buffer))))
        } catch {
            return context.eventLoop.makeFailedFuture(error)
        }
    }
    
    private func write(context: ChannelHandlerContext, stream: MessageByteStream) -> EventLoopFuture<Void> {
        let wrapOutOut = wrapOutboundOut
        let promise: EventLoopPromise<Void> = context.eventLoop.makePromise()
        stream.read { _, element in
            switch element {
            case .bytes(let buffer):
                _ = context.writeAndFlush(wrapOutOut(.body(.byteBuffer(buffer))))
            case .error(let error):
                context.flush()
                promise.fail(error)
            case .end(_):
                context.flush()
                promise.succeed(())
            }
        }
        return promise.futureResult
    }
}

extension PipelineResponseHandler {
 
    private static let debugDateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()

    private static var debugDate: String {
        debugDateFormatter.string(from: Date())
    }
    
    private var debugDate: String {
        return PipelineResponseHandler.debugDate
    }

    private func puts(code: UInt, method: String, uri: String, from: SocketAddress?) {
        let ip = from?.ipAddress ?? "-"
        let port = from?.port ?? 0
        print("[\(ip):\(port)] [\(debugDate)] [\(method)] [\(code)] \(uri)")
    }
}
