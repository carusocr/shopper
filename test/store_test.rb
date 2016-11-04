require 'minitest/autorun'
require 'minitest/capybara'
require_relative 'test_helper.rb'

class StoreTest < Minitest::Capybara::Test
	def test_safeway
		visit "http://www.safeway.com"
		assert_content "Safeway"
	end
  def test_qfc
    visit "http://www.qfc.com"

end
