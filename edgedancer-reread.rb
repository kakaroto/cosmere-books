require 'date'
require 'fileutils'
require 'nokogiri'
require_relative './methods'

FileUtils.mkdir_p('edgedancer')

BASE = 'https://www.tor.com/'.freeze

links = [
  "2017/08/24/edgedancer-reread-chapter-1/",
  "2017/08/31/edgedancer-reread-chapter-2/",
  "2017/09/07/edgedancer-reread-chapters-3-and-4/",
  "2017/09/14/edgedancer-reread-chapters-5-and-6/"
]

episode = 1

links.each do |link|
  url = BASE + link
  puts "Download #{url}"
  unless File.exist? "edgedancer/#{episode}.html"
    `wget --no-clobber "#{url}" --output-document "edgedancer/#{episode}.html" -o /dev/null`
  end
  episode += 1
end

# Now we have all the files
html = ''
for i in 1..(links.length)
  complete_html = Nokogiri::HTML(open("edgedancer/#{i}.html"))
  page = complete_html.css('.entry-content')
  title = complete_html.css('.entry-title>a').inner_html
  ending = false
  page.children.each do |e|
    ending = true if e.class? 'squib'
    e.remove if ending
  end
  html += "<h1>#{title}</h1>"
  html += page.inner_html

  url = BASE + links[i - 1]

  html += "<p>Visit <a href='#{url}'>tor.com</a> for discussion.</p>"
end

File.open('books/edgedancer-reread.html', 'w') { |file| file.write(html) }
puts '[html] Generated HTML file'

generate('edgedancer-reread', :all)
