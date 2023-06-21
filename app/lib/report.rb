class Report

  attr_reader :name, :query

  def initialize(name: , query: )
    @name = name
    @query = query
    @context = {}
    self.class.register(self) # Add this report to the registry
  end

  # Give it a column or row number, 1-indexed,
  # e.g. `row: 1` will get the first row instead of the second
  def get(col: nil, row: nil)
    col_index = col.present? ? col - 1 : nil
    row_index = row.present? ? row - 1 : nil
    if col.present? && row.nil?
      results.map { |row| row.values[col_index] }
    elsif col.nil? && row.present?
      results[row_index].values
    elsif col.present? && row.present?
      results[row_index].values[col_index]
    else
      raise <<~ERR
        I didn't expect these parameters:
          col: #{column.inspect}, row: #{row.inspect}
      ERR
    end
  end

  def with(variables)
    unless variables.is_a? Hash
      raise ArgumentError, "I expected a hash to be given to #with, but got #{variables.inspect} (#{variables.class})"
    end
    @context = variables
    return self
  end

  def results
    ActiveRecord::Base.connection.exec_query(evaluate_query).to_a
  end

  private def evaluate_query
    ERB.new(query).result_with_hash(@context)
  end

  def self.all
    registry.values
  end

  def self.find(name)
    registry.fetch(name)
  end

  def self.initialize_all
    Dir[File.expand_path("app/queries/*")].each do |path|
      base, _, ext = File.basename(path).partition(".")
      query = File.read(path)
      Report.new(name: base, query: query)
    end
  end

  def self.register(instance)
    registry.merge!(instance.name => instance)
  end

  def self.registry
    @@registry ||= Hash.new
  end

end

Report.initialize_all
