module DataTransform
  class LoadDefendants < DataTransform::Base
    def before
      puts "before"
      # Makes sure all the affiliations are in the spreadsheet
      #   (Catches a prior a CSV encoding error)
      Crtdefendant.select(:affiliation).distinct
        .map(&:affiliation).compact
        .map { |x| OrgName.find_by!("Original" => x) }
    end

    def perform
      puts "perform"
      Crtdefendant.each do |original|
        next if skip_defendant(original)
        defendant = find_or_create_defendant(original)
        find_or_create_organization(original, defendant)
        print "."
      end
      puts "perform:done"
    end

    def test_cases
      assert_equal 703, ::Organization.count
      assert_equal 1, ::Defendant.where(first_name: "George", last_name: "Zimmerman").count
    end
  end
end
