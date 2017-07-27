# coding: utf-8
PAGE_COUNT = ENV['PAGE_COUNT'].to_i || 10

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
    (1..PAGE_COUNT).each do |page|
      puts "Parsing page #{page}"
      @final_url = "#{url}#{page}"
      puts @final_url
      record_parsed_news
    end
    news
  end

  private

  def parsed_page(url_to_be_parsed)
    uri = URI(url_to_be_parsed)
    response = Net::HTTP.get(uri)
    JSON.parse(response)['items']
  end

  def news_list
    parsed_page(@final_url)
  end

  def parse_page_content(url_to_be_parsed)
    uri = URI(url_to_be_parsed)
    response = Net::HTTP.get(uri)
    page = Nokogiri::HTML(response, nil, 'iso-8898')
    page.search('article')
  end

  def record_parsed_news
    puts news_list.count
    news_list.each do |parsed_news|
      title = parsed_news['content']['title']
      image = parsed_news['content']['image']['sizes']['S'] unless parsed_news['content']['image'].nil?
      permalink = parsed_news['content']['url']
      datetime = DateTime.parse(parsed_news['publication'])
      news_content = parse_page_content(permalink)
      puts title
      puts permalink
      puts datetime
      puts "-----------------------------------------------------------------------------------------------------------------------------"
      news.push OpenStruct.new( title: title,
                                image: image,
                                permalink: permalink,
                                datetime: datetime,
                                source: source,
                                content: ReverseMarkdown.convert(news_content) )
    end
  end
end
