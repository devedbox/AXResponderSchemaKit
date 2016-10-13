Pod::Spec.new do |s|

  s.name         = 'AXResponderSchemaManager'
  s.version      = '0.1.1'
  s.summary      = 'A view controller schema manager kits.'
  s.description  = <<-DESC
                    A view controller schema manager kits used on iOS platform.
                   DESC

  s.homepage     = 'https://github.com/devedbox/AXResponderSchemaManager'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'aiXing' => '862099730@qq.com' }
  s.platform     = :ios, '7.0'

  s.source       = { :git => 'https://github.com/devedbox/AXResponderSchemaManager.git', :tag => '0.1.1' }
  s.source_files  = 'AXResponderSchemaManager/Classes/*.{h,m}'

#  s.resource  = 'AXResponderSchemaManager/Classes/*.bundle'
  s.frameworks = 'UIKit', 'Foundation'
#  s.dependency 'AXIndicatorView'
  s.requires_arc = true
end
