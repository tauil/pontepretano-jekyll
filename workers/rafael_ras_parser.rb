class RafaelRasParser < NewsParser
  private

  def record_parsed_news
    news_list.each do |parsed_news|
      title = parsed_news.search('h2').text
      image = parsed_news.at('img')
      image = image.attr('src') unless image.nil?
      permalink = parsed_news.search('h2 a').attr('href').value
      news_page = parsed_page(permalink)
      news_date = news_page.at('time').text
      datetime = DateTime.parse(news_date)
      news.push OpenStruct.new( title: title,
                                image: image,
                                permalink: permalink,
                                datetime: datetime,
                                source: source )
    end
  end
end
