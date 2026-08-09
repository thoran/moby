# test/test_helper.rb

require 'minitest/autorun'
require 'minitest-spec-context'
require 'webmock/minitest'
require 'tempfile'

require_relative '../lib/moby'

module TestFixtures
  SIMPLE_LOGIN_FORM = <<~HTML
    <html>
      <body>
        <form name="login" action="/login" method="post">
          <input type="text" name="username" />
          <input type="password" name="password" />
          <input type="submit" value="Login" />
        </form>
      </body>
    </html>
  HTML

  MULTIPLE_FORMS = <<~HTML
    <html>
      <body>
        <form name="search">
          <input type="text" name="q" />
        </form>
        <form id="login_form">
          <input type="email" name="username" id="user_email" />
          <input type="password" name="password" id="user_password" />
          <button type="submit">Submit</button>
        </form>
      </body>
    </html>
  HTML

  WORDS = %w{
    alpha bravo charlie delta echo foxtrot golf hotel india juliet
    kilo lima mike november oscar papa quebec romeo sierra tango
    uniform victor whiskey xray yankee zulu apple banana cherry date
    elder fig grape honey iris jasmine kiwi lemon mango nutmeg
  }.freeze

  WORD_LIST_FILE = Tempfile.new('moby_words').tap do |file|
    file.write(WORDS.join("\n") << "\n")
    file.flush
  end

  WORD_LIST_PATH = WORD_LIST_FILE.path
end
