require 'active_support/all'
require 'amatch'


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
  field :tag, type: String
  field :mentions, type: Integer
  field :text, type: String
  field :lemma, type: String
  field :relevance, type: Float

  belongs_to :document
  belongs_to :canonical

  before_create :store_lemma

  def store_lemma
    self.lemma = self.text.parameterize
  end
end

class Keyword
  include Mongoid::Document
  field :text, type: String
  field :relevance, type: Float

  belongs_to :document
end

class Canonical
  include Mongoid::Document
  include Amatch

  MIN_SIMILARITY = 0.9

  field :text, type: String
  field :tag, type: String
  field :representations, type: Hash, default: {}

  has_many :entities

  before_create :store_text

  def store_text
    self.text = self.representations[self.representations.keys[0]]
  end

  def add(entity)
    entities << entity
    add_representation(entity.text)
    save
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

  def valid_similarity_with(text)
    similarity_with(text) >= MIN_SIMILARITY
  end
end
