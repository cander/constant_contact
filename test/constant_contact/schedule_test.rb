require File.dirname(__FILE__) + '/../test_helper'

class ScheduleTest < Test::Unit::TestCase

  def test_collection_path
    ConstantContact::Schedule.user = 'joesflowers'
    expected = '/ws/customers/joesflowers/campaigns/123/schedules'
    found = ConstantContact::Schedule.collection_path(:campaign_id => 123)
    assert_equal(expected, found)
  end

  def test_campaign_schedule_url
    ConstantContact::Schedule.user = 'joesflowers'
    schedule = ConstantContact::Schedule.new(123, Time.now)
    expected = 'https://api.constantcontact.com/ws/customers/joesflowers/campaigns/123/schedules/1'
    assert_equal(expected, schedule.campaign_schedule_url)
  end

  context 'to_xml' do
    setup do
      ConstantContact::Base.user = "joesflowers"
      @schedule = ConstantContact::Schedule.new(123, Time.now)
    end

    should 'have Schedule tag' do
      assert_match %r!<Schedule xmlns="http://ws.constantcontact.com/ns/1.0/"!, @schedule.to_xml
      assert_match %r!id="https://api.constantcontact.com/ws/customers/joesflowers/campaigns/123/schedules/1"!, @schedule.to_xml
      assert_match %r!</Schedule>!, @schedule.to_xml
    end

    should 'have ScheduleTime tag' do
      assert_match %r!<ScheduleTime>.*</ScheduleTime>!, @schedule.to_xml
    end
  end

end
