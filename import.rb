$: << '.'
require 'api'
require 'models'


API_KEY = ENV['ALCHEMY_API_KEY']

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
