# Whale

# 20110907

# Description: Sometimes when they go fishing, they get a whale and it sinks their boat.  

# Changes since 0.5: 
# 1. 

# Todo: 
# 1. Command line options library needed really, since fixed order options is a bit blerrr.  Done as of 0.4.4, but really working as of 0.4.5.  
# 2. Be able to set the username and password fields by number.  Done as of 0.4.7.  
# 3. On-the-fly randomly generated passwords.  
# 4. Randomly generate different real user-agent strings.  
# 5. Use open proxies and/or tor at random, since any logging will identify many submissions from the same IP address and with different logins.  

# Roadmap:
# 0.5.x will have automated hooks into dslreports.com/phishtrack.  
# 0.6.x will have a generalised interface into hooking in phishing databases and will have one or two additional databases.  
# 0.7.x will offer threading for maximum throughput!  
# 0.8.x will optionally randomize submission frequency, such that a maximum and a minimum number of submissions can be set per period.  

require 'pp'

require 'rubygems'
require 'mechanize'

require 'Array/extract_optionsX'
require 'File/self.collect'
require 'Switches'

$debug = false

TLD = %w{com net org edu int mil gov arpa biz aero name coop info pro museum}
TLD_SIZE = 15

class Whale
  
  VERSION = '0.6.0'
  
  attr_accessor :options
  attr_accessor :url
  attr_accessor :form_name, :form_number
  attr_accessor :username_field_name, :username_field_number
  attr_accessor :password_field_name, :password_field_number
  attr_accessor :verbose, :username_is_email_address, :user_agent
  attr_reader :words_size
  
  def initialize(url = nil, *args)
    options = args.extract_options!
    @url = options[:url]
    @form_name = options[:f] || options[:form] || options[:form_name]
    @form_number = options[:n] || options[:form_number] || 0
    @username_field_name = options[:user_field] || options[:username_field] || options[:user_field_name] || options[:username_field_name] || options[:username_fieldname] || 'username'
    @username_field_number = options[:user_field_number] || options[:username_field_number]
    @password_field_name = options[:pass_field] || options[:password_field] || options[:pass_field_name] || options[:password_field_name] || 'password'
    @password_field_number = options[:pass_field_number] || options[:password_field_number]
    @verbose = options[:v] || options[:verbose] || false
    @username_is_email_address = options[:e] || options[:username_is_email_address] || false
    @user_agent = options[:a] || options[:user_agent] || 'Windows IE 6'
    @words_size = words.size
  end
  
  def counter_phish
    start_time = Time.now
    puts "Whale session begun #{start_time}."
    submission_count = 0
    @m = Mechanize.new
    @m.user_agent_alias = user_agent
    begin
      loop do
        set_username_field
        set_password_field
        @m.submit(form)
        pp @m.submit(form) if $debug
        submission_count += 1
        puts "#{submission_count} #{username}:#{password}" if verbose
      end
    ensure
      finish_time = Time.now
      time_delta_in_minutes = (finish_time - start_time) / 60
      submissions_per_minute = submission_count / time_delta_in_minutes
      puts "Whale session terminated #{finish_time} with #{submission_count} counter-phishes served in #{time_delta_in_minutes} minutes for an average of #{submissions_per_minute} submissions per minute."
    end
  end # def counter_phish
  
  private
  
  def words(filename = '/usr/share/dict/words')
    @words ||= File.collect(filename){|line| line.chomp}
  end
  
  def random_word
    words[rand(words_size)]
  end
  
  def random_TLD
    TLD[rand(TLD_SIZE)]
  end
  
  def page # This is a big timesaver.  I think I don't need to keep grabbing the page everytime.  
    @page ||= (
      _page = @m.get(@url)
      md = _page.body.match(/meta.*?Refresh.*?url=(.*?)"/i)
      if md
        puts 'meta_refresh_url found' if $debug
        _page = @m.get(md[1])
        pp _page if $debug
      end
      pp _page if $debug
      _page
    )
  end
  
  def form # Similarly to #page.  I don't think I need to grab the form everytime either.  
    @form ||= (
      if form_name
        page.form(form_name)
      elsif form_number
        page.forms[form_number.to_i]
      else
        page.forms[0]
      end
    )
  end
  
  def username
    if username_is_email_address
      "#{random_word}@#{random_word}.#{random_TLD}"
    else
      random_word
    end
  end
  
  def password
    random_word
  end
  
  def set_username_field
    if username_field_name
      form[username_field_name] = username
    elsif username_field_number
      form.fields[username_field_number] = username
    else
      form.fields[0] = username
    end
  end
  
  def set_password_field
    if password_field_name
      form[password_field_name] = password
    elsif password_field_number
      form.fields[password_field_number] = password
    else
      form.fields[1] = password
    end
  end
  
end
