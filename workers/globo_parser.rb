class GloboParser < NewsParser
  private

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
