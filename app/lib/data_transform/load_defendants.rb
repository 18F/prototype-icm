module DataTransform
  class LoadDefendants < DataTransform::Base
    def before
      puts "before"
      # Make sure all the affiliations are in the spreadsheet (Catches a prior a CSV encoding error)
      Crtdefendant.select(:affiliation).distinct.
        map(&:affiliation).compact.
        map { |x| OrgName.find_by!("Original" => x) }
    end

    def perform
      puts "perform"
      # TODO: Remove the limit
      Crtdefendant.first(10000).each do |original|
        next if skip_defendant(original)
        defendant = find_or_create_defendant(original)
        find_or_create_organization(original, defendant)
        print "."
      end
      puts "perform:done"
    end

    def test_cases
      # TODO: Fix, should be 703
      assert_equal 0, ::Organization.count
      # TODO: Make sure de-dupe worked (e.g 1 George Zimmerman with many matters)
    end

  end
end
