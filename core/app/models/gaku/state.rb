module Gaku
  class State < ActiveRecord::Base

    default_scope { order(:abbr) }

    has_many :addresses

    belongs_to :country, foreign_key: :country_iso, primary_key: :iso

    validates :name, :country_iso, presence: true

    def self.find_all_by_name_or_abbr(name_or_abbr)
      where('name = ? OR abbr = ?', name_or_abbr, name_or_abbr)
    end

    # table of { country.id => [ state.id , state.name ] }
    # arrays sorted by name
    # blank is added elsewhere, if needed
    def self.states_group_by_country_iso
      state_info = Hash.new { |h, k| h[k] = [] }
      State.order('name ASC').each do |state|
        state_info[state.country_iso].push [state.id, state.name]
      end
      state_info
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      i18n_name
    end

    def i18n_name
      carmen_country = Carmen::Country.coded(country_iso)
      if carmen_country && carmen_country.subregions? && carmen_country.subregions.coded(abbr)
        carmen_country.subregions.coded(abbr).name
      else
        name
      end
    end

  end
end
