Pod::Spec.new do |s| 
  s.name          = 'CORSocialManager'
  s.version       = '0.0.1'
  s.license       = 'MIT'
  s.summary       = 'CORSocialManager'
  s.homepage      = 'https://github.com/seiyavw/CORSocialManager.git'
  s.author        = "seiyavw"
  s.source        = { :git => "https://github.com/seiyavw/CORSocialManager.git", :tag => "#{s.version}"}
  s.requires_arc  = true

  s.ios.deployment_target = '6.0'

  s.source_files  = 'CORSocialManager/CORSocialManager.{h,m}'

  s.dependency  'STTwitter', '~>0.1.2' 
  
end
