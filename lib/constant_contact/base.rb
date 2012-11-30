require 'oauth'
require 'oauth_active_resource'
require 'uri'

module ConstantContact
  class Base < ActiveResource::Base
    
    self.site = "https://api.constantcontact.com"
    self.format = :atom

    DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

    class << self
      # Returns an integer which can be used in #find calls.
      # Assumes url structure with the id at the end, e.g.:
      #   http://api.constantcontact.com/ws/customers/yourname/contacts/29
      def parse_id(url)
        url.to_s.split('/').last.to_i
      end
    
      def api_key
        if defined?(@api_key)
          @api_key
        elsif superclass != Object && superclass.api_key
          superclass.api_key.dup.freeze
        end
      end

      def api_key=(api_key)
        @connection = nil
        @api_key = api_key
      end
      
      def oauth_consumer_secret
        if defined?(@oauth_consumer_secret)
          @oauth_consumer_secret
        elsif superclass != Object && superclass.oauth_consumer_secret
          superclass.oauth_consumer_secret.dup.freeze
        end
      end
      
      def oauth_consumer_secret=(oauth_consumer_secret)
        @connection = nil
        @oauth_consumer_secret = oauth_consumer_secret
      end
      
      def oauth_access_token_key
        if defined?(@oauth_access_token_key)
          @oauth_access_token_key
        elsif superclass != Object && superclass.oauth_access_token_key
          superclass.oauth_access_token_key.dup.freeze
        end
      end
      
      def oauth_access_token_key=(oauth_access_token_key)
        @connection = nil
        @oauth_access_token_key = oauth_access_token_key
      end
      
      def oauth_access_token_secret
        if defined?(@oauth_access_token_secret)
          @oauth_access_token_secret
        elsif superclass != Object && superclass.oauth_access_token_secret
          superclass.oauth_access_token_secret.dup.freeze
        end
      end
      
      def oauth_access_token_secret=(oauth_access_token_secret)
        @connection = nil
        @oauth_access_token_secret = oauth_access_token_secret
      end

      def oauth2_access_token
        if defined?(@oauth2_access_token)
          @oauth2_access_token
        elsif superclass != Object && superclass.oauth2_access_token
          superclass.oauth2_access_token.dup.freeze
        end
      end
      
      def oauth2_access_token=(oauth2_access_token)
        @connection = nil
        @oauth2_access_token = oauth2_access_token
      end

      # Adding the Bearer token seems to be the easiest way to add the
      # OAuth2 access_token to the request - see end of:
      # http://community.constantcontact.com/t5/Documentation/Authentication-using-OAuth-2-0-Server-and-Client-Flows/ba-p/38313
      # Better solution might be to subclass or monkey-patch ActiveResource::Connection
      def headers
        oauth2_access_token ? {'Authorization' => "Bearer #{oauth2_access_token}",
                                'Content-type' => "application/atom+xml" } : {}
      end

      def connection(refresh = false)
        if defined?(@connection) || superclass == Object
          if defined?(@oauth_consumer_secret) 
            @connection = OAuthActiveResource::Connection.new(
              OAuth::AccessToken.from_hash(
                OAuth::Consumer.new(api_key, oauth_consumer_secret, {
                  :site         =>  site,
                  :scheme       =>  :header,
                  :http_method  =>  :post
                }),
              :oauth_token => oauth_access_token_key,
              :oauth_token_secret => oauth_access_token_secret),
            site, format) if refresh || @connection.nil?
          elsif defined?(@oauth2_access_token)
            @connection = ActiveResource::Connection.new(site, format) if refresh || @connection.nil?
            @connection.timeout = timeout if timeout
          else
            @connection = ActiveResource::Connection.new(site, format) if refresh || @connection.nil?
            @connection.password = password if password
            @connection.timeout = timeout if timeout
            @connection.user = "#{api_key}%#{user}" if user
          end
          
          @connection
        else
          superclass.connection
        end
      end
      
      def collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "/ws/customers/#{URI.escape(self.user, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end  
      
      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        integer_id = parse_id(id)
        id_val = integer_id.zero? ? nil : "/#{integer_id}"
        "#{collection_path}#{id_val}#{query_string(query_options)}"
      end
      
      # Slight modification to AR::Base.find_every to handle instances
      # where a single element is returned. This enables calling
      # <tt>find(:first, {:params => {:email => 'sample@example.com'}})
      def find_every(options)
        # FYI: AtomFormat.decode handles the pagination from CC by
        # recursively calling get and decode - see formats/atom_format.rb
        case from = options[:from]
        when Symbol
          instantiate_collection(get(from, options[:params]))
        when String
          path = "#{from}#{query_string(options[:params])}"
          instantiate_collection(format.decode(connection.get(path, headers).body) || [])
        else
          prefix_options, query_options = split_options(options[:params])
          path = collection_path(prefix_options, query_options)
          result = format.decode(connection.get(path, headers).body)
          case result
          when Hash
            instantiate_collection( [ result ], prefix_options )
          else
            instantiate_collection( (result || []), prefix_options )
          end
        end
      end
    end
    
    # Slightly tweaked ARes::Base's implementation so all the
    # attribute names are looked up using camelcase since
    # that's how the CC API returns them.
    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s

      case method_name[-1,1]
        when "="
          attributes[method_name.chop.camelize] = arguments.first
        when "?"
          attributes[method_name.chop.camelize]
        else
          attributes.has_key?(method_name.camelize) ? attributes[method_name.camelize] : super
      end
    end

    # Caching accessor for the the id integer
    def int_id
      @id ||= self.class.parse_id(self.attributes['id'])
    end
    
    # Mimics ActiveRecord's version
    def update_attributes(atts={})
      camelcased_hash = {}
      atts.each{|key, val| camelcased_hash[key.to_s.camelize] = val}
      self.attributes.update(camelcased_hash)
      save
    end
    
    # Mimic ActiveRecord (snagged from HyperactiveResource).
    def save
      return false unless valid?
      before_save    
      successful = super
      after_save if successful
      successful
    end 
    
    def before_save
    end
    
    def after_save
    end
    
    def validate      
    end

    # So client-side validations run
    def valid? 
      errors.clear
      validate 
      super 
    end
    
    def encode
      "<entry xmlns=\"http://www.w3.org/2005/Atom\">
        <title type=\"text\"> </title>
        <updated>#{Time.now.strftime(DATE_FORMAT)}</updated>
        <author></author>
        <id>#{id.blank? ? 'data:,none' : id}</id>
        <summary type=\"text\">#{self.class.name.split('::').last}</summary>
        <content type=\"application/vnd.ctct+xml\">
        #{self.to_xml}
        </content>
      </entry>"
    end

    # TODO: Move this out to a lib
    def html_encode(txt)
      mapping = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }
      txt.to_s.gsub(/[&"><]/) { |special| mapping[special] }
    end
  end
end
