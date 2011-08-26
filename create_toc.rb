require 'nokogiri'
require 'open-uri'
require 'selenium-webdriver'


@driver = Selenium::WebDriver.for :chrome

# Open SPL login page and login
@driver.get("http://proquest.safaribooksonline.com.ezproxy.spl.org:2048/book/software-engineering-and-development/software-testing/9780321670250")

begin
  element = @driver.find_element(:name => "user")
  element.send_keys("1000015458572")
  element = @driver.find_element(:name => "pass")
  element.send_keys("3774")
  btn = @driver.find_element(:name => "Submit")
  btn.click()
  
  # Open the TOC in Nokogiri
  @doc = Nokogiri::HTML(@driver.page_source)
  @doc.at_css("div#tabtoc.tocdiv")
  
  File.open('toc.html', 'w') do | writer |
      writer << "<!DOCTYPE HTML>"
      writer << "<html>"
      writer << "<head>"
      writer << '<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />'
      writer << "</head>"
      
      writer << "<body>"
      metalist = @doc.at_css("ul.metadatalist")
      # Write book title
      writer << "<h2>" + metalist.at_css("h3.book_title").text() + "</h2>"
      # Other meta data
      writer << "<ul>"
      metalist.css("li p.data").each do | data |
        writer << "<li>" + data.text() + "</li>"
      end
      writer << "</ul>"
      
      writer << "<h3>Table Of Contents</h3>"
      
      toc = @doc.at_css("div.toc_book")
      writer << "<table style='padding:0px'>"
      
      toc.css("div").each do | item |
        loc = item.css("a").first.attributes['href'].value
        file = loc.split("/").last + ".html"
        if item.css("h4").size > 0  # Part title
          title = "<a href=\"#{file}\">#{item.text}</a>"
        elsif item.css("h5").size > 0 # Chapter title
          title = "<a style=\"padding:10px\" href=\"#{file}\">#{item.text}</a>"
        else
          title = "<a style=\"padding:20px\" href=\"#{file}\">#{item.text}</a>"
        end
        writer << "<tr><td>" + title + "</td></tr>"
      end
      writer << "</table>"
      writer << "</body></html>"
  end
  
  #@div = @driver.find_element(:css => "div#tabtoc.tocdiv")
  
  
rescue Selenium::WebDriver::Error::NoSuchElementError => e
  puts e.inspect 
ensure
  @driver.quit
end

# Read HTML from morning star
#doc = Nokogiri::HTML(open("http://quote.morningstar.com/stock/s.aspx?t=AAPL"))