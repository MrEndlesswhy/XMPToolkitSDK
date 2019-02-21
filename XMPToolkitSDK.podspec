Pod::Spec.new do |s|
  s.name         = "XMPToolkitSDK"
  s.version      = "2016.07"
  s.summary      = "Adobe XMP SDKToolkit, based on libc++"
  s.homepage     = "https://www.adobe.com/devnet/xmp.html"
  s.license      =  "MIT"
  s.author       = { "Mr Endlesswhy" => "mr.endlesswhy@foxmail.com" }

  s.ios.deployment_target = '8.0'
  
  s.source       = { :git => 'http://192.168.8.20/vender-ios/XMPToolkitSDK.git', :tag => "#{s.version}" }  
  
  s.source_files = "XMPToolkitSDK/*.h", "XMPToolkitSDK/XMPMeta.mm", "include/*.h", "include/**/*.{h, incl_cpp}", "include/**/**/*.h", "include/**/**/**/*.h"
  s.public_header_files = "XMPToolkitSDK/*.h", "include/*.h", "include/**/*.{h, incl_cpp}", "include/**/**/*.h", "include/**/**/**/*.h"
  
  s.preserve_paths = "libraries/*.a"
  s.vendored_libraries = "libraries/libXMPCoreStatic.a", "libraries/libXMPFilesStatic.a"


  s.requires_arc = true
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/include/**", "ARCHS" => "arm64" }

end
