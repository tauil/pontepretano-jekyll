# coding: utf-8
require 'uri'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'date'
require 'git'
require 'pry-byebug'

require_relative 'news_parser'
require_relative 'news_manager'
require_relative 'git_manager'

sources = [
  OpenStruct.new( name: 'globo.com',
                  url: 'http://globoesporte.globo.com/sp/campinas-e-regiao/futebol/times/ponte-preta/noticia/plantao.html',
                  loop_node: '.gui-newsfeed-list .gui-newsfeed-item-wrapper' ),
]

sources.each do |source|
  puts "Looking for news in: #{source.name}..."
  news = NewsParser.parse(source.url, source.loop_node, source.name)
  NewsManager.generate_files(news)
end

GitManager.manage

puts "Done."
