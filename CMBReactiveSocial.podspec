#
# Be sure to run `pod lib lint CMBReactiveSocial.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CMBReactiveSocial"
  s.version          = "0.1.0"
  s.summary          = "Utilities to connect with social networks with ReactiveCocoa signals"
  s.description      = <<-DESC
                       Utilities to quickly connect with social networks with ReactiveCocoa signals.
                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/stefanocomba/CMBReactiveSocial"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Stefano Comba" => "stefano.comba@gmail.com" }
  s.source           = { :git => "https://github.com/stefanocomba/CMBReactiveSocial.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/wildmonkey'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CMBReactiveSocial' => ['Pod/Assets/*.png']
  }

#s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Accounts', 'Social'
  s.dependency 'ReactiveCocoa', '2.3.1'
  s.dependency 'libextobjc/EXTScope'
s.subspec 'System' do |ss|
ss.source_files =  'Pod/Classes/Accounts/*.{m,h}'
ss.header_dir   =  'Accounts'
ss.frameworks = 'Accounts', 'Social'
end
s.subspec 'Facebook' do |ss|
ss.source_files =  'Pod/Classes/Facebook/*.{m,h}'
ss.header_dir   =  'Facebook'
ss.dependency 'Facebook-iOS-SDK'
end
s.subspec 'Google' do |ss|
ss.source_files =  'Pod/Classes/Google/*.{m,h}'
ss.header_dir   =  'Google'
ss.dependency 'google-plus-ios-sdk'
end

s.subspec 'All' do |ss|
ss.header_dir   =  'Classes'
ss.dependency 'CMBReactiveSocial/System'
ss.dependency 'CMBReactiveSocial/Facebook'
ss.dependency 'CMBReactiveSocial/Google'
end

end
