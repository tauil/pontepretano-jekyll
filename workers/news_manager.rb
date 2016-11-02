# coding: utf-8
class NewsManager
  attr_reader :news

  def initialize(news = [])
    @news = news
  end

  def self.generate_files(news)
    self.new(news).generate_files
  end

  def generate_files
    news.each_with_index do |new, index|
      current_news_date = (new.datetime.nil? ? DateTime.now : new.datetime)
      filename = [current_news_date.to_date.to_s, sanitize(new.title)].join('-')[0..79]
      body = "---\nlayout: post\ntitle: \"#{new.title.gsub('"', '\"')}\"\ndate: #{current_news_date}\nexternal_link: \"#{new.permalink}\"\ncategories: news #{new.source}\n---"

      File.open("_posts/#{filename}.markdown", "w+") do |file|
        file.write(body)
      end if (!ENV['OVERWRITE'].nil? && index <= ENV['OVERWRITE'].to_i ) || !File.file?("_posts/#{filename}.markdown")
    end
  end

  def sanitize(string)
    string.
      downcase.
      gsub(/[àáâãäå]/,'a').
      gsub(/æ/,'ae').
      gsub(/ç/, 'c').
      gsub(/[èéêë]/,'e').
      gsub(/[í]/,'i').
      gsub(/[ó]/,'o').
      gsub(/[ú]/,'u').
      gsub(' ','-').
      gsub(/[.,:;"]/, '')
  end
end
