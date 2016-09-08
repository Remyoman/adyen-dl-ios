Pod::Spec.new do |s|
  s.name             = 'AdyenDL'
  s.version          = '0.1.0'
  s.summary          = 'With AdyenDL you can dynamically list all relevant local payment methods for a specific transaction.'

  s.description      = <<-DESC
With AdyenDL you can dynamically list all relevant local payment methods for a specific transaction, so your shopper can always pay with the method of his choice. The methods are listed based on the shopper's country, the transaction currency and amount. After the shopper selects a payment method, the SDK provides a redirect URL to the payment method of choice.

This library is suited for our 250+ local payment methods.
DESC

  s.homepage         = 'https://github.com/Adyen/adyen-dl-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adyen' => 'support@adyen.com' }
  s.source           = { :git => 'https://github.com/Adyen/adyen-dl-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'AdyenDL/Classes/**/*'
  s.frameworks = 'Foundation'
end
