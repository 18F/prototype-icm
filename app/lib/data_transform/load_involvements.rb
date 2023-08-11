module DataTransform

  # @time 90 minutes
  class LoadInvolvements < DataTransform::Base
    def before
      # NO OP
    end

    def perform
      Defendant.find_each do |defendant|
        # SMELL: Looking up Crtdefendant is a lazy, hacky (= quick) way to do this.
        #   In LoadDefendants, we should keep track of the original defendants' ids.
        # Potential optimization: iterate through Matters, and associate defendants with matter
        # Potential optimization: scope to Crtdefendants whose matters exist in Crdmain
        originals = Crtdefendant.where(first_name: defendant.first_name, last_name: defendant.last_name)
        # Potential optimization: batch create
        originals.each do |original|
          Involvement.create!(
            role: :defendant,
            matter_id: original.matter_no,
            defendant: defendant
          )
        rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
          if e.message.match?(/Couldn't find Matter with 'matter_no'|Matter must exist/)
            warn "[#{self.class.name}] Could not create association"
            warn e.message
          else
            raise e
          end
        end
      end
    end

    def test_cases
      assert_equal 108607, Involvement.where(role: :defendant).count
    end
  end
end
