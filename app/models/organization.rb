require 'csv'

class Organization < ModernRecord
  has_and_belongs_to_many :defendants

  WARN_WORDS = CSV.read('app/lib/acronyms.csv', headers: true).map { |row| row["acronym"] }

  before_create do |record|
    # TODO Refactor into a named business rule
    # TODO Add terms
    overlap = (record.name.upcase.split(" ") & WARN_WORDS)
    if overlap.any?
      warn <<~MESSAGE
        This record is named: "#{record.name}"
        When naming an organization, we recommend avoiding terms:
          #{overlap.join(", ")}
        Instead, please use the full term.
      MESSAGE
    end
  end
end
