# coding: utf-8
require 'uri'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'date'
require 'git'
require 'pry-byebug'

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
    gsub(/[,:;"]/, '')
end

uri = URI('http://globoesporte.globo.com/sp/campinas-e-regiao/futebol/times/ponte-preta/noticia/plantao.html')
response = Net::HTTP.get(uri)

doc = Nokogiri::HTML(response, nil, 'iso-8898')
news_list = doc.search('.gui-newsfeed-list .gui-newsfeed-item-wrapper')

@news = []

news_list.each do |news|
  title = news.search('h3').text
  image = news.at('.gui-image-full img')
  image = image.attr('src') unless image.nil?
  permalink = news.search('a').attr('href').value
  datetime = DateTime.parse(news.search('.gui-text-datetime').text)
  @news.push OpenStruct.new(title: title, image: image, permalink: permalink, date: datetime)
end

@news.each do |new|
  current_news_date = (new.datetime.nil? ? DateTime.now : new.datetime)
  filename = [current_news_date.to_date.to_s, sanitize(new.title)].join('-')
  body = "---\nlayout: post\ntitle: \"#{new.title.gsub('"', '\"')}\"\ndate: #{current_news_date}\nexternal_link: \"#{new.permalink}\"\ncategories: news globo.com\n---"

  File.open("_posts/#{filename}.markdown", "w+") do |file|
    file.write(body)
  end unless File.file?("_posts/#{filename}.markdown")
end

git = Git.open('./')

# https://github.com/schacon/ruby-git/issues/136#issuecomment-61843461
git_files = `git --work-tree=#{git.dir} --git-dir=#{git.dir}/.git ls-files -z -d -m -o -X .gitignore`.split("\x0")
untracked = git.status.untracked.keys & git_files

if untracked.any?
  puts "Pulling data..."
  git.pull

  untracked.each do |u|
    puts "Adding #{u} to repo..."
    git.add(u) if u.match('_posts/')
  end

  if git.status.added.any?
    puts "Commiting"
    git.commit('Adds a new parsed post')
    puts "Pushing code..."
    git.push('origin', 'gh-pages')
  else
    puts "Nothing to commit"
  end
end

puts "Done."
