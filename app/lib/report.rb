require "forwardable"

class Report
  attr_reader :name, :query

  class << self
    extend Forwardable
    def_delegators :all, :count, :first, :last
  end

  def initialize(name:, query:)
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

  private def get_column_number(col)
    if col.is_a?(String)
      results.first.keys.index(col) + 1
    else
      col
    end
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

  def variables
    names = query.scan(/\{{2}\s*(.*?)\s*\}{2}/).flatten
    names.inject({}) do |memo, name|
      memo[name] = @context[name.to_sym]
      memo
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
    ActiveRecord::Base.connection.exec_query(evaluate_query).to_a
  rescue ActiveRecord::StatementInvalid => e
    puts "I tried to query with:\n\t#{evaluate_query}"
    raise e
  end

  private def evaluate_query
    unless variables.values.all? &:present?
      raise <<~MESSAGE
        This report doesn't have all the variables it needs to be evalutated.

        I expected all the variables to have non-nil values but got:
        #{variables.inspect}

        Set these variables by using #with, for example:

            Report.find("#{name}").with(#{variables.map {|k, v| "#{k}: {value}" }.join(", ")})

      MESSAGE
    end
    Mustache.render(query, @context)
  end

  def inspect
    "#<Report name: \"#{name}\" context: `#{@context.inspect}`>"
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
