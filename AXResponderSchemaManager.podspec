Pod::Spec.new do |s|

  s.name         = 'AXResponderSchemaManager'
  s.version      = '0.2.0'
  s.summary      = 'A view controller schema manager kits.'
  s.description  = <<-DESC
                    A view controller schema manager kits used on iOS platform.
                   DESC

  s.homepage     = 'https://github.com/devedbox/AXResponderSchemaManager'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'aiXing' => '862099730@qq.com' }
  s.platform     = :ios, '7.0'

  s.source       = { :git => 'https://github.com/devedbox/AXResponderSchemaManager.git', :tag => '0.2.0' }
  s.source_files  = 'AXResponderSchemaManager/Classes/*.{h,m}'

  s.resource  = 'AXResponderSchemaManager/Classes/AXResponderSchemaManager.bundle'
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
end
