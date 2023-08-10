module DataTransform
  class Base

    include Test::Unit::Assertions
    include ApplicationHelper
    include DataTransform::Common

    # Performs a data transformation in three steps
    #   1. Runs #before, which should raise an error when expected conditions are unmet
    #   2. Runs #perform, which does the data transformation work
    #   3. Runs #test_cases, which should be test/unit assertions
    # Suggestion: Wrap calls to .transform in a database transaction, so they'll rollback on error
    # Set rollback_on_error: true to do a database transaction rollback
    #   if the tests fail their assertions. Otherwise you'll just get a warning message.
    def self.perform(rollback_on_error: false)
      instance = new
      instance.before
      instance.perform
      begin
        instance.test_cases
      rescue Test::Unit::AssertionFailedError => e
        raise e if rollback_on_error
        warn "[DataTransform] Continuing despite the following error:"
        warn e.message
      end
    end

    def self.test
      instance = new
      instance.test_cases
    end

    def before
      # NO OP if not implemented
    end

    def perform
      raise NotImplementedError, "Implement #perform to run the data migration"
    end

    def test_cases
      raise NotImplementedError, "Implement #test_cases with at least one test using test/unit assertions to check the migration"
    end
  end
end
