class Report

  def initialize(name: , query: )
    @name = name
    @query = query
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

  def results
    @results ||= ActiveRecord::Base.connection.exec_query(@query).to_a
  end

end
