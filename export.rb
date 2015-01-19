$: << '.'
require 'json'

require 'boot'
require 'models'


class Dendrogram
  def self.to_json
    output = {name: 'Rick Perry Indictment', children: []}
    Document.each do |document|
      output[:children] << generate_document(document)
   end
   output.to_json
  end

  def self.generate_document(document)
    output = {name: document.title, size: document.content.size, children: []}

    entity_tags = Entity.where(document_id: document.id).pluck(:tag).uniq
    entity_tags.each do |tag|
      tmp = {name: tag, children: []}
      Entity.where(document_id: document.id, tag: tag).each do |entity|
        tmp[:children] << {name: entity.text, size: entity.mentions}
      end
      output[:children] << tmp
    end
    output
  end
end

class Treemap
  def self.generate_document(document)
    output = {name: document.title, children: []}
    Entity.where(document_id: document, tag: 'Person').each do |entity|
      output[:children] << {name: entity.text, size: entity.mentions}
    end
    output
  end

  def self.to_json
    output = {name: 'Rick Perry Indictment', children: []}
    Document.each do |document|
      output[:children] << generate_document(document)
   end
   output.to_json
  end
end

puts Dendrogram.to_json
