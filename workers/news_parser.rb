# coding: utf-8

# ActionView::Base.full_sanitizer.sanitize

class NewsParser
  attr_reader :news, :url, :loop_node, :source

  def initialize(url, loop_node, source)
    @news = []
    @url = url
    @loop_node = loop_node
    @source = source
  end

  def self.parse(url, loop_node, source)
    self.new(url, loop_node, source).parse
  end

  def parse
    record_parsed_news
    news
  end

  private

  def page
    uri = URI(url)
    response = Net::HTTP.get(uri)
    Nokogiri::HTML(response, nil, 'iso-8898')
  end

  def parse_page_content(url_to_be_parsed)
    uri = URI(url_to_be_parsed)
    response = Net::HTTP.get(uri)
    page = Nokogiri::HTML(response, nil, 'iso-8898')
    page
  end

  def parse_highlight_news(article)
    title = article.text.gsub("\n", '').strip.squeeze
    permalink = article['href']
    page_content = parse_page_content(permalink)
    news_text = page_content.at('article')

    if news_text
      datetime = DateTime.parse(page_content.at('time')['datetime']) unless page_content.at('time').nil?
      image = page_content.at('img')['src'] unless page_content.at('img').nil?
    elsif !page_content.at('span.moment').nil?
      datetime = DateTime.parse(page_content.at('span.moment')['data-fulldate'])
    end

    news.push OpenStruct.new( title: title,
                              image: image,
                              permalink: permalink,
                              datetime: datetime,
                              source: source,
                              content: ReverseMarkdown.convert(news_text) )

    if ENV['SAMPLE']
      puts title
      puts permalink
      puts datetime
      puts news_text[0..20] if news_text
      puts "\n\n"
    end
  end

  def parse_news_feed(feed_item)
    title = feed_item.at(".feed-post-body-title").text.gsub("\n", '').strip.squeeze
    permalink = feed_item.at("a")['href']

    page_content = parse_page_content(permalink)
    news_text = page_content.at('article')

    if news_text
      datetime = DateTime.parse(page_content.at('time')['datetime']) unless page_content.at('time').nil?
      image = page_content.at('img')['src'] unless page_content.at('img').nil?
    elsif !page_content.at('span.moment').nil?
      datetime = DateTime.parse(page_content.at('span.moment')['data-fulldate'])
    end

    news.push OpenStruct.new( title: title,
                              image: image,
                              permalink: permalink,
                              datetime: datetime,
                              source: source,
                              content: ReverseMarkdown.convert(news_text) )

    if ENV['SAMPLE']
      puts title
      puts permalink
      puts datetime
      puts news_text[0..20] if news_text
      puts "\n\n"
    end
  end

  def record_parsed_news
    # Highlights
    puts "Parsing Highlights"

    page.search(loop_node).each do |article|
      begin
        next if article.nil? || article.empty? || article.text.strip.chomp.empty?
        parse_highlight_news(article)
      rescue Exception => e
        binding.pry
      end
    end

    puts "Parsing News Feed"

    page.search("#feed-placeholder .post-item").each do |feed_item|
      begin
        next if feed_item.at("a")['href'].empty? || feed_item.text.strip.chomp.empty?
        parse_news_feed(feed_item)
      rescue Exception => e
        binding.pry
      end
    end
  end
end
