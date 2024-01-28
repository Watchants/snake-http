//
//  main.swift
//  snake-httpd
//
//  Created by panghu on 7/5/20.
//

import SHTTP

let bootstrap = Bootstrap(
    configuration: .init(
        host: "127.0.0.1",
        port: 8889,
        handler: .init(
            initialization: true,
            registrable: false
        )
    ),
    eventLoopGroup: .init(numberOfThreads: System.coreCount)
)

bootstrap.register(mappings: AddingsController())

let future = bootstrap.start()
bootstrap.printAddress()
try bootstrap.channelFuture?.wait().closeFuture.wait()
