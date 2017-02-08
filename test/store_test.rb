require 'minitest/autorun'
require 'minitest/capybara'
require_relative 'test_helper.rb'

=begin

Other tests:

1. Test that QFC has a gotoGridView script.
2. Test that result has a Meat & Seafood button, and clicks successfully.
3. Test that there are "item-name" and "item-price" div classes on page.
4. Test that Safeway page accepts fill_in of Search Weekly form with item, and click 'GO' works.
5. Test for existence of "CircularListItem" in div ids for Safeway.

=end

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
