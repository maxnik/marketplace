require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  tests UserMailer
  def test_recover
    @expected.subject = 'UserMailer#recover'
    @expected.body    = read_fixture('recover')
    @expected.date    = Time.now

    assert_equal @expected.encoded, UserMailer.create_recover(@expected.date).encoded
  end

end
