Pod::Spec.new do |s|

  s.name         = 'AXResponderSchemaKit'
  s.version      = '0.3.0'
  s.summary      = 'A view controller schema manager kits.'
  s.description  = <<-DESC
                    A view controller schema manager kits used on iOS platform.
                   DESC

  s.homepage     = 'https://github.com/devedbox/AXResponderSchemaKit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'aiXing' => '862099730@qq.com' }
  s.platform     = :ios, '7.0'

  s.source       = { :git => 'https://github.com/devedbox/AXResponderSchemaKit.git', :tag => '0.3.0' }
  s.source_files  = 'AXResponderSchemaKit/Classes/*.{h,m}'

  s.resource  = 'AXResponderSchemaKit/Classes/AXResponderSchemaKit.bundle'
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
end
