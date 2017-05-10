module Importer
  module Eprints
    module JsonMapper
      # Fields to ignore when processing an eprint json
      #
      # @return [Array] ignored fields
      def ignored
        [
          'lastmod',
          'uri',
          'status_changed',
          'rev_number',
          'datestamp',
          'dir',
          'source',
          'date_type',
          'userid'
        ]
      end

      # Fields that need special treatment when processing an eprint json
      #
      # @return [Array] special fields

      def special
        [
          'date',
          'full_text_status',
          'metadata_visibility',
          'eprint_status',
          'event_type',
          'event_title'
        ]
      end

      # Special fields

      def access_setting(metadata_visibility, eprint_status)
        if metadata_visibility == 'show' && eprint_status == 'archive'
          { visibility: 'open' }
        else
          { visibility: 'restricted' }
        end
      end

      def date(val, type)
        case type
        when 'published'
          { date_published: val.to_s }
        else
          { date: val.to_s }
        end
      end

      def event_title(val, event_type=nil)
        event = val
        event += " (#{event_type})" unless event_type.nil?
        { presented_at: ["#{event}"] }
      end

      # Standard fields

      # TODO: should this be a separate field?
      def alt_title(val, attributes)
        if attributes[:title].blank?
          attributes[:title] = [val]
        else
          attributes[:title] << val
        end
        attributes
      end

      def corp_creators(val, attributes)
        attributes[:creator] ||= []
        val.each do |corp|
          attributes[:creator] << corp
        end
        attributes
      end

      def creators(val, attributes)
        attributes[:creator] ||= []
        val.each do |cr|
          attributes[:creator] << make_name(cr)
        end
        attributes
      end

      def editors(val, attributes)
        attributes[:editor] ||= []
        val.each do |ed|
          attributes[:editor] << make_name(ed)
        end
        attributes
      end

      def contributors(val, attributes)
        attributes[:contributor] ||= []
        val.each do |co|
          attributes[:contributor] << make_name(co)
        end
        attributes
      end

      def abstract(val, attributes)
        attributes[:abstract] = [val]
        attributes
      end

      # TODO make this more legible
      def documents(val, attributes)
        files = []
        other_files = {}
        tmp_files_hash = {}
        val.collect { | id | tmp_files_hash[id['docid'].to_s] = id['main'] }

        val.each do |doc|
          unless doc['relation'].blank?
            version_types ||= doc['relation'].collect {| t | t['type'].gsub('http://eprints.org/relation/','') }
              if version_types.include?('isIndexCodesVersionOf')
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] ||= []
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] << { filename: doc['main'], type: 'extracted_text' }
              elsif version_types.include?('issmallThumbnailVersionOf')
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] ||= []
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] << { filename: doc['main'], type: 'thumbnail' }
              end
          else
              files << doc['main']
          end
        end
        attributes[:files] = files
        attributes[:other_files] =  other_files
        attributes
      end

      def edition(val, attributes)
        attributes[:edition] = [val.to_s]
        attributes
      end

      # pad out the identifier to 9 chars to match noid structure
      def eprintid(val, attributes)
        identifier = "ep#{val}"
        identifier.sub!('ep', 'ep0') while identifier.length < 9
        attributes[:former_id] = [val.to_s]
        attributes[:id] = identifier
        attributes
      end

      def isbn(val, attributes)
        attributes[:isbn] = [val.to_s]
        attributes
      end

      def ispublished(val, attributes)
        # TODO: lookup
        attributes[:pulication_status] = val
        attributes
      end

      def keywords(val, attributes)
        attributes[:keyword] = val.split(',').collect(&:strip)
        attributes
      end

      def note(val, attributes)
        # TODO use a different note field?
        attributes[:description] = [val]
        attributes

      end

      def number(val, attributes)
        attributes[:issue_number] = val.to_s
        attributes
      end

      def official_url(val, attributes)
        attributes[:official_url] = [val.to_s]
        attributes
      end

      def pages(val, attributes)
        attributes[:pagination] = val.to_s
        attributes

      end

      def part(val, attributes)
        attributes[:part] = [val]
        attributes

      end

      def place_of_pub(val, attributes)
        attributes[:place_of_publication] = [val]
        attributes

      end

      def pres_type(val, attributes)
        # TODO: lookup
        if attributes[:resource_type].blank?
          attributes[:resource_type] = [val]
        else
          attributes[:resource_type] << val
        end
        attributes
      end

      def publisher(val, attributes)
        attributes[:publisher] = [val]
        attributes
      end

      def refereed(val, attributes)
        if val == 'TRUE'
          attributes[:refereed] = true
        else
          attributes[:refereed] = false
        end
        attributes
      end

      def series(val, attributes)
        attributes[:series] = [val.to_s]
        attributes
      end

      def subjects(val, attributes)
        attributes[:subject] = [val.to_s]
        attributes
      end

      def title(val, attributes)
        if attributes[:title].blank?
          attributes[:title] = [val]
        else
          attributes[:title] << val
        end
        attributes
      end

      def type(val, attributes)
        # TODO: lookup
        if attributes[:resource_type].blank?
          attributes[:resource_type] = [val]
        else
          attributes[:resource_type] << val
        end
        attributes
      end

      def volume(val, attributes)
        attributes[:volume_number] = val.to_s
        attributes
      end

      private

        def make_name(name)
          "#{name['name']['family']}, #{name['name']['given']}"
        end
    end
  end
end
