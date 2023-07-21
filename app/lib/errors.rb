# This is the file for custom error types.

class QueryEvaluationError < StandardError

  attr_reader :variables, :report_name

  def initialize(variables, report_name)
    @variables = variables
    @report_name = report_name
    @variable_values = @variables.map { |k, v| "#{k}: #{v || "{value}"}" }.join(", ")
  end

  def message
    <<~MESSAGE
      This report doesn't have all the variables it needs to be evalutated.

      I expected all the variables to have non-nil values but got:
      #{@variables.inspect}

      Set these variables by using #with, for example:

          Report.find("#{@report_name}").with(#{@variable_values})

    MESSAGE
  end
end
