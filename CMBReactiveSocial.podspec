Pod::Spec.new do |s|
  s.name             = "CMBReactiveSocial"
  s.version          = "0.1.0"
  s.summary          = "A short description of CMBReactiveSocial."
  s.description      = <<-DESC
                       An optional longer description of CMBReactiveSocial

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/stefanocomba/CMBReactiveSocial"
  #s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Stefano Comba" => "stefano.comba@gmail.com" }
  s.source           = { :git => "git@github.com:stefanocomba/CMBReactiveSocial.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NAME'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.dependency 'ReactiveCocoa'
  s.default_subspec = 'All'

  s.subspec 'System' do |ss|
        ss.source_files =  'Classes/Accounts/*.{m,h}'
        ss.header_dir   =  'Accounts'
        ss.frameworks = 'Accounts', 'Social'
  end
  s.subspec 'Facebook' do |ss|
        ss.source_files =  'Classes/Facebook/*.{m,h}'
        ss.header_dir   =  'Facebook'
        ss.dependency 'Facebook-iOS-SDK'
  end
  s.subspec 'Google' do |ss|
        ss.source_files =  'Classes/Google/*.{m,h}'
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
