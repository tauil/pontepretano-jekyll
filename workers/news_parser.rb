# coding: utf-8
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

  def parsed_page(url_to_be_parsed)
    uri = URI(url_to_be_parsed)
    response = Net::HTTP.get(uri)
    Nokogiri::HTML(response, nil, 'iso-8898')
  end

  def news_list
    parsed_page(url).search(loop_node)
  end

  def title(node)
    node.search('h3').text
  end

  def image(node)
    img = node.parent.at('img')
    img.attr('src') unless img.nil?
  end

  def permalink(node)
    node.attr('href')
  end

  def record_parsed_news
    news_list.each do |parsed_news|
      news_page = parsed_page(permalink(parsed_news))
      news_date = news_page.at('time')
      news_content = news_page.at('.corpo-conteudo')
      news_images = news_page.search('.corpo-conteudo img')
      datetime = DateTime.parse(news_date)
      news.push OpenStruct.new( title: title(parsed_news),
                                image: image(parsed_news),
                                permalink: permalink(parsed_news),
                                datetime: datetime,
                                source: source,
                                content: ReverseMarkdown.convert(news_content),
                                content_îmages: news_images )
    end
  end
end
