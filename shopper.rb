#!/usr/bin/env ruby

=begin

Name: shopper.rb
Author: Chris Caruso

Script to crawl supermarket web pages and comparison shop for my frequent purchases.

*****
*need to fix chicken breasts...why are they not showing up?

=end

require 'yaml'
require 'capybara'
require 'capybara/dsl'
require 'sequel'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.javascript_driver = :chrome
Capybara.default_driver = :chrome   #should this be current or default? Explore reasons.

#added for pry testing
#include Capybara::DSL


safeway = 'http://plan.safeway.com/Circular/Seattle-2201-E-Madison-St-/2E2374900/Weekly/2'
safeway_prices = Hash.new
qfc = 'https://www.qfc.com/weeklyad?StoreCode=00847&DivisionId=705'
qfc_prices = Hash.new

cfgfile='db.yml'
abort "db.yml config file not found!" unless File.file?(cfgfile)
db_cfg = YAML::load(File.open(cfgfile))

$meaty_targets = ['Salmon','London Broil','Roast','Sardines','Chicken Breast','Chicken Thighs','Cod','Tilapia','Ground Beef','Top Round','Bottom Round','Ribeye','New York Strip','Pork Chops','Pork Tenderloin','Chicken Leg Quarters','Shrimp']
$results_hash= Hash.new {|h,k| h[k] = {}}
module Shopper
  
  class QFC
    include Capybara::DSL #figure out how to avoid this
    def get_results(store,pricelist)
      storename = 'QFC'
      visit store
      page.driver.browser.switch_to.frame(0)
      page.execute_script "wishabi.app.gotoGridView()"
      #sleep 1
      page.first(:button,"Meat & Seafood").click
      $meaty_targets.each do |m|
        page.all(:xpath,"//li[@class='item']").each do |node|
          item_name = node.first(:xpath,"./div[@class='item-name']").text
          item_price = node.first(:xpath,"./div[@class='item-price']").text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
      end
    end
  end

  class Safeway
    include Capybara::DSL
    def get_results(store, pricelist)
      storename = 'Safeway'
      visit(store)
      page.driver.browser.manage.window.resize_to(1000,1000)
      $meaty_targets.each do |m|
        page.fill_in("Search Weekly", :with => m) # works for both "Search Weekly Ads/Circular"
        page.click_button('GO')
        lastpage = page.has_link?('Next Page') ? page.first(:xpath,"//a[contains(@title,'Page')]")[:title][/ of (\d+)/,1].to_i : 0
        page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
          item_name = node.first('img')[:alt]
          item_price = node.first('p').text.sub(/with card/i,"").sub(/lb/i,"per pound")
          pricelist["#{item_name}"] = item_price
          if item_name =~ /Breasts or Thighs/
            scan_price(storename, "Chicken Breast", m, item_price)
            scan_price(storename, "Chicken Thighs", m, item_price)
          else
            scan_price(storename, item_name, m, item_price)
          end
        end
        for i in 2..lastpage
          sleep 1
          page.first(:link,"Next Page").click
          page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
            #(continue assembling hash of prices here)
            item_name = node.first('img')[:alt]
            item_price = node.first('p').text.sub(/with card/i,"")
            pricelist["#{item_name}"] = item_price
            scan_price(storename, item_name, m, item_price)
          end
        end
      end
    end

  end

end

def scan_price(storename, item_name, target_item, item_price)
  # If there is a per-pound price, ALWAYS supersede the '$ EA' price.
  if item_name =~ /#{target_item} ?/
    # set hash value if nil, otherwise set hash value if price is less?
    $results_hash[target_item][:price] ||= item_price
    $results_hash[target_item][:name] ||= item_name
    $results_hash[target_item][:store] ||= storename
    $results_hash[target_item][:price] < item_price
    # vvv Can this be cleaned up? vvv
    if item_price < $results_hash[target_item][:price] && item_price !~ /EA/ || (item_price < $results_hash[target_item][:price] =~ /EA/ && item_price =~ /EA/ && $results_hash[target_item][:price] =~ /EA/) || (item_price !~ /EA/ && $results_hash[target_item][:price] =~ /EA/)
      $results_hash[target_item][:price] = item_price
      $results_hash[target_item][:name] = item_name
    end
 end
end

def update_database(db_cfg)
  dbh = Sequel.connect(db_cfg)
  #delete old data
  dbh[:grocery_list].where('item != ?',"none of these").delete
  $results_hash.each do |k,v|
    next if v[:price] == ""
    puts "Found #{k} for #{v[:price]} at #{v[:store]}."
    #add some exception handling here
    dbh[:grocery_list].insert([:item, :price, :store], [k, v[:price], v[:store]])
  end
end

shop = Shopper::Safeway.new
shop.get_results(safeway,safeway_prices)
shop = Shopper::QFC.new
shop.get_results(qfc,qfc_prices)
update_database(db_cfg)
