# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'verzity' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
     # Pods for verzity
  	pod 'Alamofire', '~> 4.7'
  	pod 'SwiftyJSON', '~> 4.0'
  	pod 'Kingfisher', '~> 4.0'
  	#pod 'SDWebImage', '~> 4.0'
  	pod 'RealmSwift'
    pod 'FloatableTextField'
    pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
    #pod 'SVProgressHUD', :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git'
    pod 'youtube-ios-player-helper', :git=>'https://github.com/youtube/youtube-ios-player-helper', :commit=>'head'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'PayPal-iOS-SDK'
    pod 'FilesProvider'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
