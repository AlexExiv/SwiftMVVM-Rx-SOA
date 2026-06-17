source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.6'
use_frameworks!

def shared_pods
  pod 'Alamofire', '~> 5.10.1'
  pod 'RxSwift',    '~> 6.10.2'
  pod 'RxCocoa',    '~> 6.10.2'
  pod 'RxRelay',    '~> 6.10.2'
end

target 'BaseMVVM' do
    shared_pods
end

target 'BaseMVVMTests' do
    shared_pods
    
    pod 'RxBlocking', '~> 6.10.2'
    pod 'RxTest', '~> 6.10.2'
end
