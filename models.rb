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

class Canonical
  include Mongoid::Document
  field :text, type: String
  field :__type, type: String
  field :representations, type: Hash

  has_many :entities

  before_create :store_text

  def store_text
    self.text = self.representations[0][1]
  end

  def add_representation(text)
    self.representations[text.parameterize] = text
  end

  def represented?(text)
    self.representations.has_key? text.parameterize
  end

  def similarity_with(text)
    m = JaroWinkler.new(text)
    self.representations.keys.map { |rep| m.match(rep) }.sort.first
  end
end
