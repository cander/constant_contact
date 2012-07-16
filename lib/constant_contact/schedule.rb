# this is based on a "private" PDF entitled "Schedule Campaign API" that
# Constant Contact sends you after they grant your app scheduling permission.
module ConstantContact
  class Schedule < Base
    self.site += "/campaigns/:campaign_id"

    # this constructor might not work if we're instantiating a collection
    def initialize(campaign_id, schedule_time)
      super()
      # we don't pass any attributes to super because it doesn't handle
      # attributes with underscore_names in a way that works with to_xml
      # that needs CamelCaseNames.
      self.schedule_time = schedule_time
      # earlier version of ActiveResource allowed prefix_options to be
      # passed to initialize, but not anymore - I guess.
      self.prefix_options[:campaign_id] = campaign_id
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.tag!("Schedule", :xmlns => "http://ws.constantcontact.com/ns/1.0/",
              :id => campaign_schedule_url) do
         xml.tag!('ScheduleTime', self.attributes['ScheduleTime'])
       end
    end

    def id
      campaign_schedule_url
    end

    # I can't figure out the "right" way to generate this, so here's a kludge
    # According to CC's docs - that hardcoded ID 1 is OK
    def campaign_schedule_url
      id_str = "#{Base.site}#{Schedule.collection_path(prefix_options)}/1"
    end
  end
end
