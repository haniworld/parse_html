require 'nokogiri'
require 'selenium-webdriver'

class HtmlPageWriter
  
  attr_accessor :driver

  def initialize(driver)
    @driver = driver
  end
  
  def create_page(url, filepath)
    begin	
      @root = Dir.pwd
    	@driver.navigate.to url
    	
    	sleep 5

      # Log in if you have to
      element = @driver.find_element(:name => "user")
      if element != nil 
        element.send_keys("1000015458572")
        element = @driver.find_element(:name => "pass")
        element.send_keys("3774")
        btn = @driver.find_element(:name => "Submit")
        btn.click()

        # Change the view to html if not
        html_viewbtn = @driver.find_element(:id => "html")
        html_viewbtn.click unless html_viewbtn.attribute(:class).include?('active')

        wait = Selenium::WebDriver::Wait.new(:timeout => 30)
        wait.until { @driver.find_element(:css => "div.htmlcontent")}
      end

      # Strip only the html content
      @doc = Nokogiri::HTML(@driver.page_source)
      page = @doc.at_css("div.htmlcontent")

      File.open(filepath, 'w') do | writer |
          writer << "<!DOCTYPE HTML>"
          writer << "<html>"
          writer << "<head>"
          writer << '<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />'
          writer << "</head>"

          writer << "<body>"
          writer << page.to_html
          writer << "</body></html>"
      end
 
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts e.inspect
    ensure
      @driver.navigate.back
    end
  end
end