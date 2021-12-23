Pod::Spec.new do |s|
    s.name             = 'YYMediator'
    s.version          = '1.0.0'
    s.summary          = 'A mediator target-action and route url for YYMediator.'
    s.homepage         = 'https://github.com/liuxc123/YYMediator'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'liuxc123' => 'lxc_work@126.com' }
    s.source           = { :git => 'https://github.com/liuxc123/YYMediator.git', :tag => s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.source_files = 'YYMediator/Classes/**/*.{h,m}'
    
end
