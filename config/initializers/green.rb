Product.types = [ProductType::Simple]

ActiveMerchant::Billing::Base.mode = :test

Span::Green::gateway_parameters = { :login    => "stevep_1245271523_biz_api1.gmail.com", 
                                    :password => "1245271536",
                                    :signature => "AOiHunDzrFnIaaBq7EVa4Y6vQbCyA2pAMVZHaJ.wgOgqmmKcN5-jagNI"}

OrderTransaction.gateway = ActiveMerchant::Billing::PaypalGateway.new( Span::Green::gateway_parameters ) 
OrderTransaction.paypal_express_gateway = ActiveMerchant::Billing::PaypalExpressGateway.new( Span::Green::gateway_parameters )

