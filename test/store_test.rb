require 'minitest/autorun'
require 'minitest/capybara'
require './test_helper.rb'

class StoreTest < Minitest::Capybara::Test
	def test_store
		visit "http://www.safeway.com"

		assert_content "Safeway"
	end
end
