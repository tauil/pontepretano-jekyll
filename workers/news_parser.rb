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

  def record_parsed_news
    news_list.each do |parsed_news|
      title = parsed_news.search('h3').text
      image = parsed_news.at('.gui-image-full img')
      image = image.attr('src') unless image.nil?
      permalink = parsed_news.search('a').attr('href').value
      news_page = parsed_page(permalink)
      news_date = news_page.at('.materia-cabecalho time')
      datetime = DateTime.parse(news_date)
      news.push OpenStruct.new( title: title,
                                image: image,
                                permalink: permalink,
                                datetime: datetime,
                                source: source )
    end
  end
end
