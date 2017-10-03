# Generated via
#  `rails generate hyrax:work ConferenceItem`
class ConferenceItem < ::DogBiscuits::ConferenceItem
  include ::Hyrax::WorkBehavior
  include HasRendering

  self.indexer = ConferenceItemIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Conference Item'

  property :biblionumber, predicate: ::RDF::URI.new('http://london.ac.uk/ontologies/kingsfund#biblionumber') do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  # include ::Hyrax::BasicMetadata
end