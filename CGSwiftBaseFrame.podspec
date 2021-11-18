#
#  Be sure to run `pod spec lint CGSwiftBaseFrame.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it

  spec.name         = "CGSwiftBaseFrame"
  spec.version      = "0.0.1"
  spec.summary      = "一键导入基础框架库，路由跳转"

  spec.description  = <<-DESC
			
			一键导入基础框架库，路由跳转		

                   DESC

  spec.homepage     = "https://github.com/chenhde/CGSwiftBaseFrame"


 
  spec.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author             = { "chenG" => "669775990@qq.com" }


  # spec.platform     = :ios
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/chenhde/CGSwiftBaseFrame.git", :tag => "#{spec.version}" }


  spec.source_files  =  'CGSwiftBaseFrame/Classes/**/*'
 


end
