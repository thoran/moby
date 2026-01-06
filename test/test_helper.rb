# test/test_helper.rb

require 'minitest/autorun'
require 'minitest-spec-context'
require 'webmock/minitest'

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
end
