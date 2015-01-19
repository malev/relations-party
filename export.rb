$: << '.'
require 'json'

require 'boot'
require 'models'

output = {name: 'Rick Perry Indictment', children: []}


def generate_document(document)
  output = {name: document.title, children: []}

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

Document.each do |document|
  output[:children] << generate_document(document)
end

puts output.to_json
