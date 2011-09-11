require 'nokogiri'
require 'net/http'
require 'selenium-webdriver'


begin	
  @root = Dir.pwd
  
  @driver = Selenium::WebDriver.for :firefox
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
  
  # Scrap only the html content
  @doc = Nokogiri::HTML(@driver.page_source)
  page = @doc.at_css("div.htmlcontent")
  
  # Process images on the page
  img_dir = @root + '/img'
  Dir.mkdir(img_dir) unless File.directory?(img_dir)
  page.css("img").each do | image |
    img_src = image.attributes['src'].value
    # Save the image to the image folder
    socket = @driver.current_url.gsub("http://", "").split('/').first
    host = socket.split(':').first
    port = socket.split(':').last
    # Press ctrl + click
    @driver.action.key_down(:control).click(image).action.key_up(:control).perform
    4.times do
      @driver.send_keys(:arrow_down)
    end
    @driver.send_keys(:enter)
    
  end
  
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
  @driver.navigate.to('/logout?targetpage=/securelogin')
  @driver.quit
end


#title = doc.search("//table/tr[contains(@class,'gr_table')]/td")
#("table tr.gr_table_title") #.gr_table_title td

