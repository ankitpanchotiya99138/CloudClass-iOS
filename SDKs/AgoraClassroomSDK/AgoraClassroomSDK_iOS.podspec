Pod::Spec.new do |spec|
  spec.name             = 'AgoraClassroomSDK_iOS'
  spec.version          = '1.1.5.2'
  spec.summary          = 'Education scene SDK'
  spec.description      = 'Agora Classroom SDK'

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => 'classroom_v' + "#{spec.version.to_s}" }

  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  
  spec.subspec 'PreRtc' do |pre_rtc|
    pre_rtc.source_files  = "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/**/*.{swift,h,m}", "AgoraClassroomSDK/**/*.{swift,h,m}"
    pre_rtc.public_header_files = [
      "AgoraClassroomSDK/Public/*.h",
      "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/Public/*.h"
    ]
    
    # close source libs
    pre_rtc.dependency "AgoraEduCorePuppet/PreRtc"
    pre_rtc.dependency "AgoraEduCore/PreRtc"

    # common libs
    pre_rtc.dependency "AgoraExtApp"
    pre_rtc.dependency "AgoraWidget"

    # open source libs
    pre_rtc.dependency "AgoraEduUI"
    pre_rtc.dependency "AgoraEduContext"
    pre_rtc.dependency "AgoraWidgets"
  end
  
  spec.subspec 'ReRtc' do |re_rtc|
    re_rtc.source_files  = "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/**/*.{swift,h,m}", "AgoraClassroomSDK/**/*.{swift,h,m}"
    re_rtc.public_header_files = [
      "AgoraClassroomSDK/Public/*.h",
      "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/Public/*.h"
    ]
    
    # close source libs
    re_rtc.dependency "AgoraEduCorePuppet/ReRtc"
    re_rtc.dependency "AgoraEduCore/ReRtc"

    # common libs
    re_rtc.dependency "AgoraExtApp"
    re_rtc.dependency "AgoraWidget"

    # open source libs
    re_rtc.dependency "AgoraEduUI"
    re_rtc.dependency "AgoraEduContext"
    re_rtc.dependency "AgoraWidgets"
  end

  spec.default_subspecs = 'PreRtc'
end
