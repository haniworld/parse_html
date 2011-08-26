require 'nokogiri'
require 'selenium-webdriver'


begin	
driver = Selenium::WebDriver.for :firefox
	driver.get "file:///Users/haniworld/Downloads/s.aspx.html" #{}"http://quote.morningstar.com/stock/s.aspx?t=AAPL"

  puts driver.class.to_s
  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  wait.until { driver.find_element(:xpath => "//li/a") != nil}
  element = driver.find_element :xpath => "//li/a"
	#element = driver.find_element :xpath => "//h1" 

	

rescue Selenium::WebDriver::Error::NoSuchElementError => e
  puts e.inspect
ensure
  driver.quit
end


#title = doc.search("//table/tr[contains(@class,'gr_table')]/td")
#("table tr.gr_table_title") #.gr_table_title td

#title.each do | t | 
#	puts t.text
#end
# Should display Apple Inc.