#!/usr/bin/env ruby
# Downloads information pages from ANN linked from the "browse all shows, sort
# by date" page OR the pages linked by other pages if no description was given

links = []
while line = $<.gets
#  line =~ /HREF="(.*)".*FONT COLOR.*">(.*)<\/FONT>.*SIZE="1">(.*)<\/TD>/
#  links << [$1, $2, $3]
  line =~ /<p>(.*)<\/p>/
  links << $1
end
=begin
links.each do |link|
  date = link[2].split('-')
  if date[1].to_i.between?(3, 5)
    url = "http://www.animenewsnetwork.com" + link[0]
    puts url
    id = link[0][/\d+$/]
    `curl -o shows/#{id}.html "#{url}"`
    sleep 30
  end
end
=end
links.each do |link|
  url = "http://www.animenewsnetwork.com" + link
  puts url
  id = link[/\d+$/]
  `curl -so shows/manga/#{id}.html "#{url}"`
  sleep 30
end
