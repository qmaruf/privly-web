class Payment < ActiveRecord::Base
  PAYMENT_PROVIDERS = [['Paypal', 'paypal'], ['Braintree', 'braintree',], ['Bitcoin', 'bitcoin']]
end
