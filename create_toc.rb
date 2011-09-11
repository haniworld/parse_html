load 'htmlpagewriter.rb'
require 'amqp'

@toc_url = ARGV[0]
puts @toc_url
@book_dir = "test_dir"
@driver = Selenium::WebDriver.for :firefox

# Open SPL login page and login
@driver.get(@toc_url)

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
  
  Dir.mkdir(@book_dir) unless File.directory?(@book_dir)
  puts "success"
  File.open(@book_dir + '/toc.html', 'w') do | writer |
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
      
      page_writer = HtmlPageWriter.new(@driver)
      toc.css("div").each do | item |
        loc = item.css("a").first.attributes['href'].value
        file = @book_dir + "/" + loc.split("/").last + ".html"
        page_writer.create_page(loc, file)
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
rescue Selenium::WebDriver::Error::NoSuchElementError => e
  puts e.inspect 
ensure
  @driver.quit
end

