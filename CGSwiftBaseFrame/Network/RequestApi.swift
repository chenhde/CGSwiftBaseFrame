//
//  RequestApi.swift
//  Pods
//
//  Created by chenG on 2021/11/22.
//

import Foundation

public enum RequestApi {
    
    /// 登录
    public static let login = "/ncdpMemberShipService/v1/patientAccount/patientLoginByPwd"
    
   
    
}
public extension RequestApi {

    /// 非透传域名
    static var domain: String {
        
        return "https://csserver.kanghehealth.com"
    }
}
