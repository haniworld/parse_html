require 'nokogiri'
require 'selenium-webdriver'


begin	
  @driver = Selenium::WebDriver.for :chrome
	@driver.get "http://proquest.safaribooksonline.com.ezproxy.spl.org:2048/book/web-development/ruby/9780321669919/distributed-message-queues/ch08"

  element = @driver.find_element(:name => "user")
  if element != nil 
    element.send_keys("1000015458572")
    element = @driver.find_element(:name => "pass")
    element.send_keys("3774")
    btn = @driver.find_element(:name => "Submit")
    btn.click()
    
    # Change the view to html
    html_viewbtn = @driver.find_element(:id => "html")
    html_viewbtn.click unless html_viewbtn.attribute(:class).include?('active')
    
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until { @driver.find_element(:css => "div.htmlcontent")}
  end
  
  # Open the TOC in Nokogiri
  @doc = Nokogiri::HTML(@driver.page_source)
  page = @doc.at_css("div.htmlcontent")
  
  # Process images on the page
  
  
  File.open('test.html', 'w') do | writer |
      writer << "<!DOCTYPE HTML>"
      writer << "<html>"
      writer << "<head>"
      writer << '<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />'
      writer << "</head>"
      
      writer << "<body>"
      writer << page.to_html
      writer << "</body></html>"
  end
  
  #element = driver.find_element :xpath => "//li/a"
	#element = driver.find_element :xpath => "//h1" 
rescue Selenium::WebDriver::Error::NoSuchElementError => e
  puts e.inspect
ensure
  @driver.quit
end


#title = doc.search("//table/tr[contains(@class,'gr_table')]/td")
#("table tr.gr_table_title") #.gr_table_title td

