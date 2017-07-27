# coding: utf-8
require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'
require 'ostruct'
require 'date'
require 'git'
require 'pry-byebug'
require 'reverse_markdown'

require_relative 'news_parser'
require_relative 'rafael_ras_parser'
require_relative 'news_manager'
require_relative 'git_manager'

sources = [
  OpenStruct.new( name: 'globo.com',
                  url: 'http://falkor-cda.bastian.globo.com/feeds/a3564c2f-a0c4-403c-bfd6-c3a201d95452/posts/page/',
                  loop_node: '#glb-corpo .gui-feed-title',
                  parser: 'NewsParser'),
  OpenStruct.new( name: 'Blog Rafael Ras',
                  url: 'http://globoesporte.globo.com/sp/campinas-e-regiao/blogs/especial-blog/torcedor-da-ponte-preta/1.html',
                  loop_node: '.posts li',
                  parser: 'RafaelRasParser'),
]
sources = sources[0..0] if ENV['SAMPLE']
sources.each do |source|
  puts "#{Time.now} Looking for news in: #{source.name}..."
  news = Object.const_get(source.parser).parse(source.url, source.loop_node, source.name)
  if !ENV['SAMPLE']
    puts "#{Time.now} Parsed #{news.size} news from #{source.name}."
    NewsManager.generate_files(news)
    puts "#{Time.now} Generated files."
  end
end

if GitManager.manage
  puts "#{Time.now} Pushed code."
else
  puts "#{Time.now} Nothing to commit."
end

puts "#{Time.now} Done."
