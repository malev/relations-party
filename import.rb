require 'mongoid'
require 'httparty'

API_KEY = ENV['ALCHEMY_API_KEY']

Mongoid.load!("mongoid.yml", :development)
Mongoid.logger = Logger.new($stdout)
Moped.logger = Logger.new($stdout)

links = %W(
http://www.texastribune.org/2014/08/19/perry-booking/
http://www.texastribune.org/2014/08/16/five-things-know-about-perry-indictment/
http://www.texastribune.org/2014/08/19/rally-perry-planned-courthouse/
http://www.chron.com/news/houston-texas/article/Rick-Perry-s-day-A-mug-shot-then-ice-cream-5699211.php
http://www.foxnews.com/politics/2014/08/25/perry-team-turns-mug-shot-into-fundraising-shirt/
http://www.huffingtonpost.com/2014/08/22/rick-perry-mugshot_n_5701472.html
http://kut.org/post/governor-perry-facing-possible-grand-jury-indictment
http://www.cnn.com/2014/08/15/politics/rick-perry-indictment/index.html
http://www.huffingtonpost.com/2014/08/15/rick-perry-indicted-power_n_5683406.html
https://en.wikipedia.org/wiki/Indictment_of_Rick_Perry
http://kxan.com/2014/11/07/prosecutor-jury-should-hear-perry-felony-case/
http://kxan.com/2014/10/24/perrys-1st-court-appearance-now-set-for-nov-6/
http://kxan.com/2014/11/17/perry-defense-veto-was-constitutionally-protected/
http://www.dallasnews.com/news/politics/state-politics/20140820-rick-perry-indictment.ece
http://abcnews.go.com/blogs/politics/2014/08/texas-gov-rick-perry-indicted-by-grand-jury/
http://www.washingtonpost.com/politics/texas-gov-rick-perry-indicted-for-abuse-of-office-coercion/2014/08/15/d173907c-24d5-11e4-958c-268a320a60ce_story.html
)


class Document
  include Mongoid::Document
  field :url, type: String
  field :title, type: String
  field :content, type: String
  field :language, type: String
  field :published_at, type: DateTime

  has_many :entities
  has_many :keywords
end

class Entity
  include Mongoid::Document
  field :_type, type: String
  field :mentions, type: Integer
  field :text, type: String
  field :relevance, type: Float

  belongs_to :document
end

class Keyword
  include Mongoid::Document
  field :text, type: String
  field :relevance, type: Float

  belongs_to :document
end

class BaseExtractor
  class ApiError < RuntimeError; end
  include HTTParty
  base_uri "access.alchemyapi.com/"

  def initialize(query = {})
    query = {
      apikey: API_KEY,
      outputMode: 'json'
    }.merge(query)

    @options = {
      query: query
    }
  end

  def call
    @call ||= _call
  end

  def _call
    response = get(text_path, @options)
    if response.parsed_response['status'] = 'OK'
      response.parsed_response
    else
      raise ApiError
    end
  end

  def text_path
    raise NotImplemented
  end

  def get(url, options={})
    self.class.get(url, options)
  end
end

class TextExtractor < BaseExtractor
  def text_path
    '/calls/url/URLGetText'
  end
end

class TitleExtractor < BaseExtractor
  def text_path
    '/calls/url/URLGetTitle'
  end
end

class EntitiesExtractor < BaseExtractor
  def text_path
    '/calls/url/URLGetRankedNamedEntities'
  end
end

class KeywordsExtractor < BaseExtractor
  def text_path
    '/calls/url/URLGetRankedKeywords'
  end
end

def process(links)
  links.each do |link|
    text_extractor = TextExtractor.new(url: link)
    entities_extractor = EntitiesExtractor.new(url: link)
    keywords_extractor = KeywordsExtractor.new(url: link)

    document = Document.create(
      url: link,
      title: TitleExtractor.new(url: link).call['title'],
      content: text_extractor.call['text'],
      language: text_extractor.call['language']
    )

    entities_extractor.call['entities'].each do |entity|
      Entity.create(
        document: document,
        _type: entity['type'],
        relevance: entity['relevance'].to_f,
        mentions: entity['count'].to_i,
        text: entity['text']
      )
    end

    keywords_extractor.call['keywords'].each do |keyword|
      Keyword.create(
        document: document,
        relevance: keyword['relevance'].to_f,
        text: keyword['text']
      )
    end
  end
end

process(links)
