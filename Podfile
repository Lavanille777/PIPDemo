source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'  #设定支持ios最低版本
install! 'cocoapods', deterministic_uuids: false
use_frameworks! #固定参数不要改，设置全局支持静态库和动态库混合方式
inhibit_all_warnings! #关闭第三方库警告

target 'PIPDemo' do
pod 'RxSwift'
pod 'RxCocoa'
pod 'SnapKit'
pod 'LookinServer', :configurations => ['Debug']
pod 'TYSnapshotScroll'
end
