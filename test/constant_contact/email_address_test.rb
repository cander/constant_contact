require File.dirname(__FILE__) + '/../test_helper'

class EmailAddressTest < Test::Unit::TestCase

  context 'looking up account emails' do
    setup do
      ConstantContact::Base.user = "joesflowers"
      ConstantContact::Base.password = "password"
      ConstantContact::Base.api_key = "api_key"
      stub_get('https://api_key%25joesflowers:password@api.constantcontact.com/ws/customers/joesflowers/settings/emailaddresses',
      'account_email_address.xml')
    end

    should 'find an email address' do
      url = ConstantContact::EmailAddress.find('joesflowers@example.com').id
      assert_equal 'http://api.constantcontact.com/ws/customers/joesflowers/settings/emailaddresses/1', url
    end
  end

end
