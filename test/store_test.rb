require 'minitest/autorun'
require 'minitest/capybara'
require_relative 'test_helper.rb'

class StoreTest < Minitest::Capybara::Test
  def setup
    @safeway = 'http://plan.safeway.com/Circular/Seattle-2201-E-Madison-St-/2E2374900/Weekly/2'
    @qfc = 'https://www.qfc.com/weeklyad?StoreCode=00847&DivisionId=705'
  end
	def test_safeway
		visit @safeway
		assert_content "Weekly"
	end
  def test_qfc
    visit @qfc
    assert_content "My Store"
  end

end
