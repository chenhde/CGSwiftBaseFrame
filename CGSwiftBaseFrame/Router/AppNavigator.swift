//
//  AppNavigator.swift
//  CGSwiftBaseFrame
//
//  Created by chenG on 2021/11/19.
//

import Foundation
import Runtime
import SafariServices
import URLNavigator
@_exported import KakaJSON

public typealias RouterParams = [String: Any?]

public let AppNavigator = Navigator()

public enum URLGenerator {
    /// 默认的domain
    case path(_ path: String)
    /// 自定义domain
    case url(domain: String, path: String)

    func hostUrl() -> String {
        switch self {
        case let .path(value):
            return "myapp://\(value.lowercased())"
        case let .url(domain, path):
            return "\(domain)://\(path.lowercased())"
        }
    }
}

// MARK: 路由跳转

public extension Navigator {
    @discardableResult
    func push(_ url: URLGenerator, params: RouterParams? = nil) -> UIViewController? {
        push(url.hostUrl(), context: params)
    }

    @discardableResult
    func present(_ url: URLGenerator, params: RouterParams? = nil, wrap: UINavigationController.Type? = nil, modalStyle: UIModalPresentationStyle? = nil) -> UIViewController? {
        if let modalStyle = modalStyle {
            guard let vc = controller(for: url, params: params, wrap: wrap) else {
                return nil
            }
            vc.modalPresentationStyle = modalStyle
            UIViewController.topMost?.present(vc, animated: true, completion: nil)
            return vc
        } else {
            return present(url.hostUrl(), context: params)
        }
    }
    @discardableResult
    func controller(for url: URLGenerator, params: RouterParams? = nil, wrap: UINavigationController.Type? = nil) -> UIViewController? {
        if let wrap = wrap {
            guard let vc = viewController(for: url.hostUrl(), context: params) else {
                return nil
            }
            return (vc is UINavigationController) ? vc : wrap.init(rootViewController: vc)
        } else {
            return viewController(for: url.hostUrl(), context: params)
        }
    }
}

public struct RouterMap: Convertible {
    public var className: String = ""
    public var xib: String?
    public var identify: String?
    public var storyboard: String?

    private var url: String {
        return URLGenerator.path(className).hostUrl()
    }

    public init() {}

    /// 注册web路由
    public static func register() {
        /// 解析配置表
        let plist = Bundle.main.path(forResource: "RouterMap", ofType: "plist")!
        guard let list = NSArray(contentsOfFile: plist) as? [Any] else {
            return
        }
        guard let maps = modelArray(from: list, type: RouterMap.self) as? [RouterMap] else {
            return
        }
        maps.forEach { model in

            AppNavigator.register(model.url) { _, _, content in
                guard let clss = NSClassFromString(model.className) as? UIViewController.Type else {
                    return nil
                }
                let bundle = Bundle(for: clss)
                /// 创建storyboard的控制器
                var controller = UIViewController()
                if let identify = model.identify, let storyboard = model.storyboard {
                    controller = UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identify)
                } else if let storyboard = model.storyboard {
                    controller = UIStoryboard(name: storyboard, bundle: bundle).instantiateInitialViewController()!
                } else if let xib = model.xib {
                    /// 创建xib的控制器
                    controller = clss.init(nibName: xib, bundle: bundle)
                } else {
                    /// 创建init的控制器
                    controller = clss.init()
                }
                /// 参数赋值
                if let params = content as? RouterParams {
                    if model.className.contains(".") { /// Swift类的参数赋值
                        /// 获取类信息
                        guard let info = try? typeInfo(of: type(of: controller)) else {
                            return controller
                        }
                        /// 类属性赋值
                        info.properties.forEach { property in
                            guard let value = params[property.name] else { return }
                            /// 防止字典里的value为nil
                            guard !((value as? AnyObject)?.isKind(of: NSNull.self) ?? false) else { return }
                            do {
                                try controller.setValue(value, forKey: property.name)
                            } catch {}
                        }
                    } else { /// OC 类的参数赋值
                        params.forEach { key, value in
                            do {
                                try controller.setValue(value, forKey: key)
                            } catch {}
                        }
                    }
                }
                return controller
            }
        }
        /// 注册web路由
        AppNavigator.register("http://<path:_>", webControllerFactory)
        AppNavigator.register("https://<path:_>", webControllerFactory)
    }

    /// Web路由回调
    private static func webControllerFactory(url: URLConvertible, values _: [String: Any], context _: Any?) -> UIViewController? {
        guard let url = url.urlValue else { return nil }
        return SFSafariViewController(url: url)
    }
}
