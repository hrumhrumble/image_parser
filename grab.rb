#!/usr/bin/env ruby

require 'nokogiri'
require 'open_uri_w_redirect_to_https'
require 'fileutils'

class Grabber

  def initialize(argv)
    @url = argv.shift
    @path = argv.shift
  end

  def http(url)
    @url_regex = /^(https?\:\/\/)?(www\.)?([^\/.]*?\.)(.+)/

    if @url_regex =~ url
      parsed_url = URI.parse(url)
      if parsed_url.scheme == 'http' || parsed_url.scheme == 'https'
        url
      else
        "http://#{url}"
      end
    else
      puts "Sorry, wrong url. Only accept: www.example.com, example.com, http(s)://www.example.com, http(s)://example.com"
    end
  end

  def create_folder(path)
    if File.exist?(path)
      @path
    else
      FileUtils.mkpath(path).first
    end
  end

  def page_source
    Nokogiri::HTML(open(http(@url)))
  end

  def image_url_cleaner(img)
    if /^http/ !~ img
      if /^\/\// =~ img
        img.gsub(/^\/\//, "http://")
      elsif /^\// =~ img
        img.gsub(/^\//, "http://#{@url}/")
      else
        img
      end
    else
      img
    end
  end

  def images
    page_source.search('img').map { |img| image_url_cleaner(img['src']) }.compact
  end

  def download(image, folder)
    file_name = File.basename(image.to_s)

    File.open("#{folder}/#{file_name}", 'wb') do |fo|
      fo.write open(image, redirect_to_https: true).read
    end
  end

  def go
    folder = create_folder(@path)
    threads = []
    puts 'download images...'

    images.each do |image|
      threads << Thread.new { download(image, folder) }
    end

    threads.each(&:join)
  end
end

if __FILE__ == $0
  Grabber.new(ARGV).go
end
