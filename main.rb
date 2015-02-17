require './crawler'

crawler = Crawler.new site: "http://mau-gto.rcode5.com/", depth: 2
crawler.crawl
