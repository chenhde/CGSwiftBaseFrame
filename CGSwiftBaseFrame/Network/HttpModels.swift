//
//  HttpModels.swift
//  CGSwiftBaseFrame
//
//  Created by chenG on 2021/11/22.
//

import Foundation

public struct FileModel {
    var data: Data
    var fileName: String
    var fileKey: String
    var mimeType: String

    public init(image: UIImage, fileKey: String = "file") {
        data = image.pngData()!
        fileName = "\(Date().timeIntervalSince1970).png"
        self.fileKey = fileKey
        mimeType = "image/png"
    }
}

/// 基础的网络请求模型类（通用）
public struct ResponModel<Target>: Convertible {
    public var code: Int?
    public var message: String?
    public var success: Bool?
    public var content: Target?
    public init() {}
}
/// 基础的网络请求模型类（自定义）
public struct OtherResponModel<Target>: Convertible {
    public var code: Int = 0
    public var msg: String?
    public var rows: Target?
    public var total: Int = 0

    public init() {}
}
/// 基础的网络请求模型类（空模型）
public struct EmptyModel: Convertible {
    public init() {}
}
/// 基础的网络请求模型类（错误信息）
public struct ErrorModel: Convertible {
    public var error: String?
    public var message: String?
    public var path: String?
    public var status: Int = 0
    public var timestamp: String?

    public init() {}
}

