require "forwardable"

# Overwrites Mustache's open and close tags
require_relative "./ext/mustache.rb"
require_relative "./errors.rb"

class Report
  PARSER = Mustache::Parser.new
  OTAG = Regexp.escape(PARSER.otag)
  CTAG = Regexp.escape(PARSER.ctag)

  attr_reader :id, :name, :query

  class << self
    extend Forwardable
    def_delegators :all, :count, :first, :last
  end

  def initialize(id:, name:, query:)
    @id = id
    @name = name
    @query = query
    @context = {}
    self.class.register(self) # Adds this report to the registry
  end

  def get(col: nil, row: nil)
    return results if col.nil? && row.nil?
    row_num, row_was_text = get_row_number(row)

    get_by_number(
      col: get_column_number(col),
      row: row_num,
      row_was_text: row_was_text
    )
  end

  # Handle when there is no column
  private def get_column_number(col)
    first_result = results.first
    return col unless col.is_a?(String)
    maybe_key = first_result.keys.index(col)
    if maybe_key.nil?
      raise ArgumentError, <<~MESSAGE
        I couldn't find #{col} in this list of columns:
        #{first_result.keys.join(", ")}
      MESSAGE
    end
    maybe_key + 1
  end

  private def get_row_number(row)
    if row.is_a?(String)
      result = results.map { |row| row.values.first }.index(row) + 1
      [result, true]
    else
      [row, false]
    end
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

  private def tag_matcher
    @matcher ||= Regexp.new("#{OTAG}\s*(.*?)\s*#{CTAG}")
  end

  def variables
    names = query.scan(tag_matcher).flatten
    names.each_with_object({}) do |name, memo|
      memo[name] = @context[name.to_sym]
    end
  end

  def with(variables)
    unless variables.is_a? Hash
      raise ArgumentError, "I expected a hash to be given to #with, but got #{variables.inspect} (#{variables.class})"
    end
    @context = variables
    self
  end

  def results
    return @stubbed_results if @stubbed_results.present?
    @results ||= ActiveRecord::Base.connection.exec_query(evaluate_query).to_a
  rescue ActiveRecord::StatementInvalid => e
    puts "I tried to query with:\n\n#{evaluate_query}"
    raise e
  end

  def clear_results
    @results = nil
  end

  private def evaluate_query
    unless variables.values.all?(&:present?)
      raise QueryEvaluationError.new(variables, name)
    end
    Mustache.render(query, @context)
  end

  def inspect
    "#<Report id: #{id}, name: \"#{name}\", context: `#{@context.inspect}`>"
  end

  def to_s
    inspect
  end

  def self.all
    registry.values
  end

  def self.find(identifier)
    if identifier.is_a? Numeric
      find_by_id(identifier)
    elsif identifier.is_a? String
      find_by_name(identifier)
    end
  end

  def self.find_by_id(id)
    all[id - 1].dup
  end
  private_class_method :find_by_id

  def self.find_by_name(name)
    key = name.parameterize
    registry.fetch(key) {
      raise ActiveRecord::RecordNotFound, <<~ERR
        I couldn't find a report named "#{name}".
        Create it by adding `app/queries/#{key}.sql`.

      ERR
    }.dup
  end
  private_class_method :find_by_name

  def self.initialize_all
    Dir[File.expand_path("app/queries/*")].each.with_index do |path, i|
      base, _, _ext = File.basename(path).partition(".")
      query = File.read(path)
      Report.new(id: i+1, name: base, query: query)
    end
  end

  def self.register(instance)
    registry.merge!(instance.name.parameterize => instance)
  end

  def self.registry
    @@registry ||= {}
  end

  def stub_results(return_value)
    @stubbed_results = return_value
  end

  def clear_stubbed_results
    @stubbed_results = nil
  end
end

Report.initialize_all
