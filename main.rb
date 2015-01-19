$: << '.'
require 'boot'
require 'active_support/all'
require 'amatch'
require 'models'


Entity.pluck(:tag).uniq.each do |tag|
  Entity.where(tag: tag).each do |entity|
    canonical = Canonical.where(tag: tag).detect { |canonical| canonical.valid_similarity_with(entity.lemma) }

    if canonical.nil?
      canonical = Canonical.create tag: tag, representations: {entity.lemma => entity.text}
      canonical.entities << entity
      canonical.save
    else
      canonical.add(entity)
    end
  end
end
