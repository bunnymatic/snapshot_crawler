require './poltergeist_crawler'
require 'pry'
require 'uri'
class Crawler < PoltergeistCrawler
  DEFAULT_OPTIONS = {
    depth: 5
  }

  attr_reader :site, :depth

  def initialize(opts = nil)
    options = DEFAULT_OPTIONS.merge(opts || {})
    raise StandardError.new("You must specify a site in the options with the key :site") unless options[:site]
    @site = options[:site]
    @depth = options[:depth]
    @visited = {}
    super()
  end
  
  def crawl(path = nil, current_depth = 0)
    return if current_depth >= @depth

    current_depth += 1
    path ||= @site
    path.gsub! /\/\/$/, '/'
    screenshot_file = screenshot_from_path(path)

    puts "Saving #{path} to #{screenshot_file}"

    visit_path = @site + path
    visit visit_path
    screenshot(screenshot_file)
    @visited[visit_path] = path

    puts page.all('a[href]').map{|x| x[:href]}

    page.all('a[href]').each do |link|
      visit_path = @site + link
      
      next if @visited.has_key? visit_path
      crawl visit_path + link[:href], 1
    end
  end

  def screenshot_from_path(p)
    path = p.gsub(/^https?:\/\//, '').gsub(/\/$/, '').gsub(/[[:punct:]]/, '-')
    path = 'root' if (/^\s?$/ =~ path || !path)
    path
  end
end
