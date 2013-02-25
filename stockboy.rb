#!/usr/bin/env ruby

# Working on a script that crawls supermarket pages and comparison shops for me.

require 'mechanize'
require 'nokogiri'
require 'open-uri'

agent = Mechanize.new
agent.get('http://superfreshfood.inserts2online.com/customer_Frame.jsp?drpStoreID=747&showFlash=false').search("Store").each do |page|
	puts page.content
end
agent.get('http://superfreshfood.inserts2online.com/customer_Frame.jsp?drpStoreID=747&showFlash=false').search('.//*[@id="itemName0"]')
doc = Nokogiri::HTML(open('http://superfreshfood.inserts2online.com/customer_Frame.jsp?drpStoreID=747&showFlash=false'))
puts doc.content

doc.search('Store').each do |link|
	puts link.content
end

puts 'test'
