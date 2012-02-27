#!/usr/bin/env ruby
# Extracts information from an ANN page and outputs an HTML snippet containing
# it. Makes use of extra pages that were downloaded if necessary (no
# description given)
# Run with:
#   for f in *.html; do ruby parse.rb $f; echo $f; done
# Super slow but whatever.

require 'hpricot'
require 'date'

class Show
  attr_accessor :title, :description, :type
  attr_accessor :staff, :date, :check, :pic, :abbv
end

class Staff
  attr_accessor :director, :original, :studio
end

doc = Hpricot(File.open(ARGV[0]).read)

show = Show.new
show.staff = Staff.new
title = doc.at('#page_header').inner_text
show.title = title[/^[^\(]+/].strip
show.type = title[/\((.*)\)$/][1..-2]

show.abbv = show.title.downcase.gsub(' ', '-').delete("^a-z", "^0-9")[0..10]

doc.search('div.encyc-info-type').each do |x|
  if x.inner_text =~ /^Plot Summary/
    show.description = x.at('span').inner_text
  elsif x.inner_text =~ /^Vintage/
    vintage = x.at('span').inner_text.split('-').map(&:to_i)
    if vintage.length < 3
      d = Date.new(*vintage)
      show.date = d.strftime("%B")
    else
      d = Date.new(*vintage)
      show.date = d.strftime("%B %-d")
    end
  end
end

doc.search('div.ENTAB').each do |x|
  t = x.at('b').inner_text
  a = x.at('a').inner_text
  case
  when t =~ /Director/i
    show.staff.director = a
  when t =~ /Original creator/i
    show.staff.original = a
  when t =~ /Animation Production/i
    show.staff.studio = a
  end
end

def find_desc(doc, show)
  if show.description == nil
    if (i = doc.at('#content-zone').at('small')) != nil
      return if (check = i.at('a')) == nil
      check = check['href']
      newdoc = Hpricot(File.open("manga/#{check[/\d+$/]}.html"))
      newdoc.search('div.encyc-info-type').each do |x|
        if x.inner_text =~ /^Plot Summary/i
          show.description = x.at('span').inner_text
          break
        end
      end
    end
  end
end
find_desc(doc, show)

puts <<END
		<article class=#{show.type.downcase} id=#{show.abbv}>
			<div class=pic><img src=""></div>
			<h1>#{show.title}</h1>
			<time>#{show.date}</time>
			<p>#{show.description or 'no description...'}</p>
			<ul class=info>
				<li><h2>Original Work</h2><p>#{show.staff.original}</p>
				<li><h2>Director</h2><p>#{show.staff.director}</p>
				<li><h2>Animation</h2><p>#{show.staff.studio}</p>
			</ul>
		</article>
END
