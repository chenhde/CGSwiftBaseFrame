//
//  ReadMe.swift
//  CGSwiftBaseFrame
//
//  Created by chenG on 2021/11/19.
//

/**
  路由集成
  1、在AppDelegate的didFinishLaunchingWithOptions中注册
 /// 路由注册
 RouterMap.register()
 2、创建RouterMap.plist文件
 3、复制RouterGenerator.py文件到根目录
 4、在build phases 中设置 RouterGenerator.py 执行

 
 传参相关
 /// NOTE1: 路由参数相关属性需要用@objc修饰属性或者@objcMembers修饰类
 var userId: String = ""
 /// NOTE2: 路由参数如果有block属性，需要用Any修饰，使用block再进行可选类型绑定
 var handler: Any?
 /// NOTE3: 路由参数支持继承自NSObject的class参数，不支持struct
 var person: Person = Person()
 /// NOTE4: 路由参数支持Int类型
 var number: Int = 0

 
 
 
*/
