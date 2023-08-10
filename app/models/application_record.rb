class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  connects_to database: {reading: :legacy, writing: :legacy}

  Diffing = Module.new do
    def -(other)
      diff_active_record(self, other)
    end

    private def diff_active_record(base, head)
      unless base.instance_of?(head.class)
        raise ArgumentError, "must be same classes, but trying to diff #{base.class} and #{head.class}"
      end
      keys = (base.attributes.to_a - head.attributes.to_a).map(&:first)
      from_values = base.values_at(keys)
      head_values = head.values_at(keys)
      memo = {}
      keys.zip(from_values.zip(head_values)).each do |k, vals|
        memo[k] = {from: vals.first, to: vals.last}
      end
      memo
    end
  end

  using Diffing # Refinement
end
