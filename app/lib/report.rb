require 'forwardable'

class Report

  attr_reader :name, :query

  class << self
    extend Forwardable
    def_delegators :all, :count, :first, :last
  end

  def initialize(name: , query: )
    @name = name
    @query = query
    @context = {}
    self.class.register(self) # Adds this report to the registry
  end

  def get(col: nil, row: nil)
    col_num = if col.is_a?(String)
      results.first.keys.index(col) + 1
    else
      col
    end

    row_num = if row.is_a?(String)
      row_was_text = true
      results.map { |row| row.values.first }.index(row) + 1
    else
      row_was_text = false
      row
    end

    get_by_number(col: col_num, row: row_num, row_was_text: row_was_text)
  end

  # Give it a column or row number, 1-indexed,
  # e.g. `row: 1` will get the first row instead of the second
  private def get_by_number(col: nil, row: nil, row_was_text: false)
    col_index = col.present? ? col - 1 : nil
    row_index = row.present? ? row - 1 : nil
    if col.present? && row.nil?
      results.map { |row| row.values[col_index] }
    elsif col.nil? && row.present?
      start = row_was_text ? 1 : 0
      results[row_index].values[start..]
    elsif col.present? && row.present?
      results[row_index].values[col_index]
    else
      raise <<~ERR
        I didn't expect these parameters:
          col: #{col.inspect}, row: #{row.inspect}
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
    return @stubbed_results if @stubbed_results.present?
    ActiveRecord::Base.connection.exec_query(evaluate_query).to_a
  end

  private def evaluate_query
    Mustache.render(query, @context)
  end

  def inspect
    "#<Report name: \"#{self.name}\">"
  end

  def self.all
    registry.values
  end

  def self.find(name)
    key = name.parameterize
    registry.fetch(key) {
      raise ActiveRecord::RecordNotFound, <<~ERR
        I couldn't find a report named \"#{name}\".
        Create it by adding `app/queries/#{key}.sql`.

      ERR
    }
  end

  def self.initialize_all
    Dir[File.expand_path("app/queries/*")].each do |path|
      base, _, ext = File.basename(path).partition(".")
      query = File.read(path)
      Report.new(name: base, query: query)
    end
  end

  def self.register(instance)
    registry.merge!(instance.name.parameterize => instance)
  end

  def self.registry
    @@registry ||= Hash.new
  end

  def stub_results(return_value)
    @stubbed_results = return_value
  end

  def clear_stubbed_results
    @stubbed_results = nil
  end

end

Report.initialize_all
