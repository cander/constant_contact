ConstantContact
===============
This is a very ActiveResource-like ruby wrapper to the Constant Contact
API. See the [ActiveResource::Base docs](http://api.rubyonrails.org/classes/ActiveResource/Base.html) for more information on how to use this ActiveResource-based wrapper.

This gem is not quite done yet, and there are several forks - see the
[Network Graph](https://github.com/timcase/constant_contact/network).
None of them seems to be authoritative, nor does the original parent seem
to be actively maintained.  I was using OAuth2, and I couldn't figure out 
how to get that working with the forks I found.  So, I created yet another one.
Enjoy.

Authorization
--------

All examples require setting up either the specific class you'll be use or the Base object before use:

### Basic Auth

    ConstantContact::Base.api_key = 'api-key'
    ConstantContact::Base.user = 'user'
    ConstantContact::Base.password = 'password'


### OAuth1

*I haven't used the original OAuth (v.1) from the
[wishery fork](https://github.com/wishery/constant_contact), but this is
how I think it would work.*

    ConstantContact::Base.api_key = 'api-key'
    ConstantContact::Base.user = 'user'
    ConstantContact::Base.oauth_consumer_secret = 'secret'
    ConstantContact::Base.oauth_access_token_key = 'token'
    ConstantContact::Base.oauth_access_token_secret = 'secret'

### OAuth2

    ConstantContact::Base.api_key = 'api-key'
    ConstantContact::Base.user = 'user'
    ConstantContact::Base.oauth2_access_token = 'access-token'


Examples
--------


### Find Lists

    ConstantContact::List.find(1)
    ConstantContact::List.find :all

### Find A Contact


    ConstantContact::Contact.find(1)
    ConstantContact::Contact.find(:first, :params => {:email => 'jon@example.com'})
    ConstantContact::Contact.find_by_email('jon@example.com') # => same as previous line

### Create a Contact (with rescue if it already exists)

    # Contact not found. Create it.
    begin
      @contact = ConstantContact::Contact.new(
        :email_address => "jon@example.com",
        :first_name => "jon",
        :last_name => "smith"
      )
      @contact.save
    rescue ActiveResource::ResourceConflict => e
      # contact already exists
      puts 'Contact already exists. Saving contact failed.'
      puts e
    end

### Find a Contact By Email Address, Check if They're a Member of the Default List

    c = ConstantContact::Contact.find_by_email('jon@example.com')
    @contact = ConstantContact::Contact.find(c.int_id) # Because Constant Contact doesn't return a full contact when searching by email
    puts 'In default contact list.' if @contact.contact_lists.include?(1) # contact_lists is an array of list ids

Development and Testing
-----------------------

I created a Gemfile (independent of the gemspec) that works for me - your
milage may vary.  To install the gems:

    bundle install --path vender/bundle

To run the tests:

    bundle exec rake

Debugging
---------

One of the most annoying things to figure out is when Constant Contact
rejects a submission with a 400 HTTP error code.  When that happens, a
```BadRequest``` exception is raised out of
```ActiveResource::Connection```.  The
```to_s``` method on that isn't helpful, but you can get the full text of the
error message from Constant Contact via: ```ex.response.body```.

---

Copyright (c) 2009 Timothy Case, released under the MIT license
