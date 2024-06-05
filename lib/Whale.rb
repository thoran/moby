# Whale.rb
# Whale

require 'pp'

require 'mechanize'

require 'File/self.collect'

class Whale

  TLD = %w{com net org edu int mil gov arpa biz aero name coop info pro museum}

  attr_accessor\
    :debug,
    :form_name,
    :form_number,
    :password_field_name,
    :password_field_number,
    :url,
    :user_agent,
    :username_field_name,
    :username_field_number,
    :username_hostname,
    :username_is_email_address,
    :verbose

  def initialize(
    debug: false,
    form_name: nil,
    form_number: 0,
    password_field_name: 'password',
    password_field_number: 1,
    url: nil,
    user_agent: nil,
    username_field_name: 'username',
    username_field_number: 0,
    username_hostname: nil,
    username_is_email_address: false,
    verbose: false
  )
    @debug = debug
    @form_name = form_name
    @form_number = form_number
    @password_field_name = password_field_name
    @password_field_number = password_field_number
    @url = url
    @user_agent = user_agent
    @username_field_name = username_field_name
    @username_field_number = username_field_number
    @username_hostname = username_hostname
    @username_is_email_address = username_is_email_address
    @verbose = verbose
  end

  def mechanize
    @mechanize ||= Mechanize.new
  end

  def counter_phish
    start_time = Time.now
    puts "Whale session begun #{start_time}."
    submission_count = 0
    begin
      loop do
        set_user_agent
        set_username_field
        set_password_field
        result = mechanize.submit(form)
        pp result if @debug
        submission_count += 1
        puts "#{submission_count} #{username}:#{password}" if @verbose
      end
    ensure
      finish_time = Time.now
      time_delta_in_minutes = (finish_time - start_time) / 60
      submissions_per_minute = submission_count / time_delta_in_minutes
      puts "Whale session terminated #{finish_time} with #{submission_count} counter-phishes served in #{time_delta_in_minutes} minutes for an average of #{submissions_per_minute} submissions per minute."
    end
  end

  private

  def words(filename = '/usr/share/dict/words')
    @words ||= File.collect(filename){|line| line.chomp}
  end

  def random_word
    words[rand(words.size)]
  end

  def random_TLD
    TLD[rand(TLD.size)]
  end

  def random_user_agent
    agent_aliases = Mechanize::AGENT_ALIASES
    agent_aliases.delete('Mechanize')
    agent_aliases_keys = agent_aliases.keys
    agent_aliases_keys[rand(agent_aliases.size)]
  end

  def page
    @page ||= (
      _page = mechanize.get(@url)
      md = _page.body.match(/meta.*?Refresh.*?url=(.*?)"/i)
      if md
        puts 'meta_refresh_url found' if @debug
        _page = mechanize.get(md[1])
        pp _page if @debug
      end
      pp _page if @debug
      _page
    )
  end

  def form
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
      if username_hostname
        "#{random_word}@#{username_hostname}"
      else
        "#{random_word}@#{random_word}.#{random_TLD}"
      end
    else
      random_word
    end
  end

  def password
    random_word
  end

  def set_user_agent
    if @user_agent
      mechanize.user_agent_alias = @user_agent
    else
      mechanize.user_agent_alias = random_user_agent
    end
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
