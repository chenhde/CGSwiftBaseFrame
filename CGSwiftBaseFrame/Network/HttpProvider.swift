//
//  HttpProvider.swift
//  CGSwiftBaseFrame
//
//  Created by chenG on 2021/11/22.
//

import Foundation
import Moya

/// 网络请求类，具体使用参考Moya官方文档
public let HttpTool = MoyaProvider<ApiRequest>()

public enum ApiRequest {
    
    case request(domain: String, path: String?, bodyParams: [String: Any]? = nil, queryParams: [String: Any]?, method: Moya.Method)

    case upload(domain: String, path: String?, params: [String: Any]?, files: [FileModel], method: Moya.Method)

    case download(domain: String, path: String?, params: [String: Any]?)
    
    
    /// GET请求封装
    /// - Parameters:
    ///   - domain: 域名
    ///   - path: 请求路径, ⚠️注意⚠️ ：不能在路径中拼接参数。
    ///   - params: 请求参数
    /// - Returns: ApiRequest
    public static func get(domain: String = RequestApi.domain, path: String? = nil, params: [String: Any]? = nil) -> ApiRequest {
        return ApiRequest.request(domain: domain, path: path, bodyParams: nil, queryParams: params, method: .get)
    }

    /// POST请求封装
    /// - Parameters:
    ///   - domain: 域名
    ///   - path: 请求路径, ⚠️注意⚠️ ：不能在路径中拼接参数。
    ///   - bodyParams: body参数
    ///   - queryParams: query参数
    /// - Returns: ApiRequest
    public static func post(domain: String = RequestApi.domain, path: String? = nil, bodyParams: [String: Any]? = nil, queryParams: [String: Any]? = nil) -> ApiRequest {
        return ApiRequest.request(domain: domain, path: path, bodyParams: bodyParams, queryParams: queryParams, method: .post)
    }

    /// 文件上传
    /// - Parameters:
    ///   - domain: 域名
    ///   - path: 请求路径, ⚠️注意⚠️ ：不能在路径中拼接参数。
    ///   - params: 请求参数
    ///   - files: 文件数组
    /// - Returns: ApiRequest
    public static func upload(domain: String = RequestApi.domain, path: String?, params: [String: Any]? = nil, files: [FileModel]) -> ApiRequest {
        return ApiRequest.upload(domain: domain, path: path, params: params, files: files, method: .post)
    }
    
    
    
    
    
    
}

extension ApiRequest: TargetType {
    public var baseURL: URL {
        switch self {
        case let .request(domain, _, _, _, _), let .upload(domain, _, _, _, _), let .download(domain, _, _):
            return URL(string: domain)!
        }
    }
    
    public var path: String {
        switch self {
        case let .request(_, path, _, _, _), let .upload(_, path, _, _, _), let .download(_, path, _):
            return path ?? ""
        }
    }
    
    public var method: Moya.Method {
        
        switch self {
        case let .request(_, _, _, _, method), let .upload(_, _, _, _, method):
            return method
        case .download:
            return .get
        }
    }
    
    public var task: Task {
        
        switch self {
        case let .request(_, _, bParams, qParams, _):

            if let bParams = bParams, let qParams = qParams {
                let bData = try! JSONSerialization.data(withJSONObject: bParams, options: [])
                return .requestCompositeData(bodyData: bData, urlParameters: qParams)
            } else if let bParams = bParams {
                let bData = try! JSONSerialization.data(withJSONObject: bParams, options: [])
                return .requestData(bData)
            } else if let qParams = qParams {
                return .requestParameters(parameters: qParams, encoding: URLEncoding.default)
            } else {
                return .requestPlain
            }

        case let .upload(_, _, params, files, _):
            let array = files.map { model -> MultipartFormData in
                let formData = MultipartFormData(provider: .data(model.data), name: model.fileKey, fileName: model.fileName, mimeType: model.mimeType)
                return formData
            }
            let params = params ?? [:]
            return .uploadCompositeMultipart(array, urlParameters: params)

        case let .download(_, _, params):
            let params = params ?? [:]
            return .downloadParameters(parameters: params, encoding: JSONEncoding.default, destination: defaultDownloadDestination)
        }
    }
    
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    
}

/// 默认的文件下载目录
private let defaultDownloadDestination: DownloadDestination = { _, response in
    (ApiRequest.downloadDestination.appendingPathComponent(response.suggestedFilename!), [])
}


public extension ApiRequest {
    /// 文件下载存储目录
    static var downloadDestination: URL {
        var fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        fileUrl = fileUrl.appendingPathComponent("HttpProvider", isDirectory: true)
        if FileManager.default.fileExists(atPath: fileUrl.absoluteString) == false {
            do {
                try FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return URL(fileURLWithPath: NSHomeDirectory())
            }
        }
        return fileUrl
    }

    /// 下载目录下文件是否存在
    /// - Parameter fileName: 文件名
    /// - Returns: Bool
    static func isFileExists(_ fileName: String) -> Bool {
        let filePath = downloadDestination.appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: filePath)
    }
}


