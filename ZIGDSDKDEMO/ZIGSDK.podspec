Pod::Spec.new do |spec|
  spec.name         = "ZIGSDK"
  spec.version      = "1.1.0"
  spec.summary      = "A lightweight network SDK built with Alamofire for simple API requests."
  spec.description  = <<-DESC
                         ZIGSDK is a robust and lightweight network SDK that leverages Alamofire to simplify making
                       network requests in iOS applications. It handles HTTP requests, manages responses, and simplifies
                       error handling. This SDK is suitable for projects that require interaction with RESTful APIs.
                       It also provides support for JSON parsing and offers flexible configurations for network layers.
                       DESC
  spec.homepage     = "https://github.com/Kamalguna972/ZIGSDKDEMO"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Kamalesh" => "kamalesh2002.gk@gmail.com" }
  spec.platform = :ios, '12.0'
  spec.source       = { :git => "https://github.com/Kamalguna972/ZIGSDKDEMO.git", :tag => spec.version.to_s }
  spec.source_files  = 'MySDKDevelopment/**/*.{swift,h,m}'
  spec.frameworks   = 'Foundation'
  spec.dependency 'Alamofire', '~> 5.4'
  spec.dependency 'RealmSwift', '~> 10.0'
  spec.swift_versions = ['5.7']
end
