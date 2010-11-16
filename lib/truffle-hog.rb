module TruffleHog
  VERSION = "0.0.3"
  
  def self.parse_feed_urls(html, favor = :all, opts = {})
    rss_links  = scan_for_tag(html, "rss", opts[:include_relative])
    atom_links = scan_for_tag(html, "atom", opts[:include_relative])

    case favor
    when :all
      (rss_links + atom_links).uniq
    when :rss
      rss_links.empty? ? atom_links : rss_links
    when :atom
      atom_links.empty? ? rss_links : atom_links
    end
  end
  
  def self.scan_for_tag(html, type, include_relative = false)
    urls(html, "link", type, include_relative) + urls(html, "a", type, include_relative)
  end
  
  def self.urls(html, tag, type, include_relative = false)
    tags = html.scan(/(<#{tag}.*?>)/).flatten
    feed_tags = collect(tags, type)
    feed_tags.map do |tag|
      matches = tag.match(/.*href=['"](.*?)['"].*/)
      if matches.nil?
        url = ""
      else
        url = matches[1]
      end
      if include_relative
        url
      else
        url =~ /^http.*/ ? url : nil
      end
    end.compact
  end
  
  def self.collect(tags, type)
    tags.collect {|t| t if feed?(t, type)}.compact
  end
  
  def self.feed?(html, type)
    html =~ /.*type=['"]application\/#{type}\+xml['"].*/
  end
end
