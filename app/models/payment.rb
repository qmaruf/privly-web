require 'activemerchant'

class Payment < ActiveRecord::Base
  PAYMENT_PROVIDERS = [['Paypal', 'paypal'], ['Braintree', 'braintree',], ['Bitcoin', 'bitcoin']]
  ActiveMerchant::Billing::Base.mode = :test

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :number     => '4111111111111111',
      :month      => '8',
      :year       => '2015',
      :first_name => 'Tobias',
      :last_name  => 'Luetke',
      :verification_value  => '123'
    )
  end

  def braintree_gateway
    ActiveMerchant::Billing::BraintreeBlueGateway.new(
      :merchant_id => '',
      :public_key => '',
      :private_key => ''
    )
  end

  def paypal_gateway
    gateway = ActiveMerchant::Billing::PaypalGateway.new(
      :login => '',
      :password => '',
      :signature => ''
    )
  end

  def brain_tree
    amount = 123
    if credit_card.valid?
      response = braintree_gateway.authorize(amount, credit_card)
      puts response.inspect
      puts response.success?
    end
  end

  def paypal
    amount = 123
    if credit_card.valid?
      response = paypal_gateway.authorize(amount, credit_card, :ip => '127.0.0.1')
      puts response.inspect
      puts response.success?
    end
  end

end
