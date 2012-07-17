require File.dirname(__FILE__) + '/../test_helper'

class CampaignTest < Test::Unit::TestCase

  context 'looking up account emails' do
    setup do
      ConstantContact::Base.user = "joesflowers"
      ConstantContact::Base.password = "password"
      ConstantContact::Base.api_key = "api_key"
      stub_get('https://api_key%25joesflowers:password@api.constantcontact.com/ws/customers/joesflowers/settings/emailaddresses',
      'account_email_address.xml')
      @email_url = 'http://api.constantcontact.com/ws/customers/joesflowers/settings/emailaddresses/1'
      @campaign = ConstantContact::Campaign.new
    end

    should 'lookup a from email address' do
      @campaign.from_email = 'joesflowers@example.com'
      assert_equal @email_url, @campaign.from_email_url
    end

    should 'accept from address URL w/o looking it up' do
      @campaign.from_email_url = @email_url
      assert_equal @email_url, @campaign.from_email_url
    end

    should 'default reply-to address to from address' do
      @campaign.from_email_url = @email_url
      assert_equal @email_url, @campaign.reply_to_email_url
    end

    should 'allow separate reply-to address url' do
      @campaign.from_email_url = 'http://totally/different'
      @campaign.reply_to_email_url = @email_url
      assert_equal @email_url, @campaign.reply_to_email_url
    end

    should 'lookup a reply-to address' do
      @campaign.from_email_url = 'http://totally/different'
      @campaign.reply_to_email = 'joesflowers@example.com'
      assert_equal @email_url, @campaign.reply_to_email_url
    end
  end

  # setting the URL results in no web lookup

  # reply-to defaults to from

end
