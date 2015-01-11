require 'httparty'


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
