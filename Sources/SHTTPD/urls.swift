//
//  urls.swift
//  snake-httpd
//
//  Created by panghu on 9/1/20.
//

import SHTTP
import Foundation

class IndexController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/"
    
    @RequestMapping("/*", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var index: String
}

class NewsController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/news"
    
    @RequestMapping("/c", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var c: String
    
    @RequestMapping("/b", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var b: String
    
    @RequestMapping("/{query}", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var query: String
}

class GettingController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/get"
    
    @RequestMapping("/a", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var a: String
    
    @RequestMapping("/b", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var b: String
}

class UserController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/user"
    
    @RequestMapping("/", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var request: String
    
    @RequestMapping("/get", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var get: String
    
    @RequestMapping("/get/value/*", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var value: String
}

class NewsXController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/news/x"
    
}

class GettingXController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/get/x"
    
}

class UserXController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/user/x"
}

class GetExample: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/get"
    
    @RequestMapping("/", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let head = HTTPResponseHead(version: .init(major: 2, minor: 0), status: .ok)
        let body = MessageBody(json: [
            "code": 200,
            "method": "GET",
            "message": "success"
        ])
        let response = MessageResponse(head: head, body: body)
        promise.succeed(response)
        return promise.futureResult
    })
    var request: String
}

class PostExample: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/post"
    
    @RequestMapping("/request", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let head = HTTPResponseHead(version: .init(major: 2, minor: 0), status: .ok)
        let body = MessageBody(json: [
            "code": 200,
            "method": "POST",
            "message": "success"
        ])
        let response = MessageResponse(head: head, body: body)
        promise.succeed(response)
        return promise.futureResult
    })
    var request: String
}

class FileExample: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/download/file"
    
    @RequestMapping("/", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        var head = HTTPResponseHead(version: .init(major: 2, minor: 0), status: .ok)
        head.headers.add(name: "Content-Type", value: "applicatioon/json")
        let body = MessageBody(json: [
            "code": 200,
            "method": "File",
            "message": "success"
        ])
        let file = FileHandle(forWritingAtPath: "/tmp/file.zip")
        let response = MessageResponse(head: head, body: body)
        request.body.stream?.read { _, element in
            switch element {
            case .bytes(var buffer):
                if let data = buffer.readData(length: buffer.readableBytes) {
                    file?.write(data)
                }
            case .error(let error):
                promise.fail(error)
            case .end(_):
                promise.succeed(response)
            }
        }
        return promise.futureResult
    })
    var request: String
}

class AddingsController: RequestController, RequestControllerProtocol {
    
    let mapping: String = "/addings"
    
    @RequestMapping("/*", { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var request: String
    
    @RequestMapping("/get", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var get: String
    
    @RequestMapping("/get/value/*", method: [.GET], { request, channel, token in
        let promise = channel.eventLoop.makePromise(of: MessageResponse.self)
        let response = MessageResponse(head: .ok, body: .init(json: []))
        promise.succeed(response)
        return promise.futureResult
    })
    var value: String
}
