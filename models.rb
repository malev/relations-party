require 'mongoid'


Mongoid.load!("mongoid.yml", :development)
Mongoid.logger = Logger.new($stdout)
Moped.logger = Logger.new($stdout)


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
