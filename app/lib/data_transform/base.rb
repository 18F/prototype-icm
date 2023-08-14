module DataTransform
  class Base
    include Test::Unit::Assertions
    include ApplicationHelper
    include DataTransform::Common

    # Performs a data transformation in three steps
    #   1. Runs #before, which should raise an error when expected conditions are unmet
    #   2. Runs #perform, which does the data transformation work
    #   3. Runs #test_cases, which should be test/unit assertions
    # Set raise_on_error: true to raise, which will rollback the transaction
    #   if the tests fail their assertions. Otherwise you'll just get a warning message.
    # Set in_transaction: false if you don't want it to run in a transaction
    def self.perform(raise_on_error: false, in_transaction: true)
      instance = new
      instance.before
      instance.perform
      begin
        instance.test_cases
      rescue Test::Unit::AssertionFailedError => e
        raise e if raise_on_error
        warn "[#{name}] Continuing despite the following error:"
        warn e.message
      end
    end

    private_class_method def self._perform(raise_on_error: false, in_transaction: true)
      ModernRecord.transaction do
        perform(raise_on_error: raise_on_error, in_transaction: in_transaction)
      end
    end

    def self.test
      return true if ENV.fetch("RAILS_ENV") == "test"
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
