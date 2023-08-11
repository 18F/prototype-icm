module DataTransform
  class LoadDefendants < DataTransform::Base
    def before
      # Makes sure all the affiliations are in the spreadsheet
      #   (Catches a prior a CSV encoding error)
      Crtdefendant.select(:affiliation).distinct
        .map(&:affiliation).compact
        .map { |x| OrgName.find_by!("Original" => x) }
    end

    def perform
      Crtdefendant.named.find_each do |original|
        defendant = find_or_create_defendant(original)
        find_or_create_organization(original, defendant)
        print "."
      end
    end

    def test_cases
      assert_equal 703, ::Organization.count
      assert_equal 1, ::Defendant.where(first_name: "GEORGE", last_name: "ZIMMERMAN").count
    end
  end
end
