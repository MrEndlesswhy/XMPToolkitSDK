
Pod::Spec.new do |spec|

  spec.name         = "XMPToolkitSDK"
  spec.version      = "201607.1"
  spec.summary      = "Adobe XMPToolkitSDK for writing jpeg metadata"
  spec.description  = <<-DESC
        Adobe XMPToolkitSDK for writing jpeg metadata for ios.
                   DESC

  spec.homepage     = "https://www.adobe.com/devnet/xmp/sdk/eula.html"
  spec.license      = { :type => "BSD", :file => "LICENSE" }

  spec.author             = { "Evan Xie" => "mr.evan.xie@foxmail.com" }
  spec.platform     = :ios, "8.0"
  spec.requires_arc = true

  spec.source       = { :git => "git@192.168.8.20:vender-ios/XMPToolkitSDK.git", :tag => "#{spec.version}" }

  spec.source_files  = "XMPToolkitSDK/*.{h,mm}", "include/*.{hpp,h,incl_cpp}", "include/**/*.{hpp,h,incl_cpp}", "include/**/**/*.{hpp,h,incl_cpp}", "include/**/**/**/*.{h,incl_cpp}"

  spec.preserve_paths = "include/*.{hpp,h,incl_cpp}", "include/**/*.{hpp,h,incl_cpp}", "include/**/**/*.{hpp,h,incl_cpp}", "include/**/**/**/*.{h,incl_cpp}"

  spec.vendored_libraries = "libraries/libXMPFilesStatic.a", "libraries/libXMPCoreStatic.a"

  spec.compiler_flags = '-fembed-bitcode', '-I${SRCROOT/include}'

  spec.xcconfig = {
    'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/XMPToolkitSDK/include',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'IOS_ENV=1'
  }

  spec.public_header_files = "XMPToolkitSDK/*.h"

end
