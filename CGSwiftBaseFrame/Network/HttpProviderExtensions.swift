//
//  HttpProviderExtensions.swift
//  CGSwiftBaseFrame
//
//  Created by chenG on 2021/11/22.
//

import Foundation
import Moya
import RxSwift

extension Response {
    /// 将网络请求数据进行json字典转换
    func jsonMap<T>(_: T.Type) throws -> T? {
        if let model = data.kj.model(ResponModel<T>.self) {
            if model.code == 200 {
                return model.content
            } else {
                throw NSError.instance(model.message)
            }
        } else if let model = data.kj.model(ErrorModel.self), (model.status ?? 0) > 0 {
            throw NSError.instance("\(model.status)：\(model.error ?? "")")
        } else {
            throw NSError.instance(CommonErrorTips)
        }
    }

    func otherJsonMap<T>(_: T.Type) throws -> T? {
        if let model = data.kj.model(OtherResponModel<T>.self) {
            if model.code == 1 {
                return model.rows
            } else if let msg = model.msg {
                throw NSError.instance(msg)
            } else {
                throw NSError.instance(CommonErrorTips)
            }
        } else {
            throw NSError.instance(CommonErrorTips)
        }
    }

}

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func jsonMap<T: Convertible>(_: T.Type) -> Single<T?> {
        return flatMap { Single.just(try $0.jsonMap(T.self)) }
    }

    func arrayMap<T: Sequence>(_: T.Type) -> Single<T?> where T.Element: Convertible {
        return flatMap { Single.just(try $0.jsonMap(T.self)) }
    }

    func baseMap<T: Codable>(_: T.Type) -> Single<T?> {
        return flatMap { Single.just(try $0.jsonMap(T.self)) }
    }

    func otherJsonMap<T: Convertible>(_: T.Type) -> Single<T?> {
        return flatMap { Single.just(try $0.otherJsonMap(T.self)) }
    }
}

public extension MoyaProvider where Target: Moya.TargetType {
    func request(_ req: ApiRequest) -> Single<Response> {
        return HttpTool.rx.request(req)
    }
}


public let CommonErrorTips = "网络异常，请稍后再试！"

public extension Error {
    var description: String {
        localizedDescription ?? CommonErrorTips
    }
}

public extension NSError {
    static func instance(_ desc: String?, code: Int = 0) -> NSError {
        return NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: desc ?? CommonErrorTips])
    }
}
