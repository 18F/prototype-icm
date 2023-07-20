# Overwrite Mustache's parser with Oracle SQL's opening and closing tags
#   so that we don't have to change the queries when we add them.

require 'mustache' # SMELL: This is likely unnecessary.

class Mustache::Parser
  def initialize(options = {})
    @options = options
    @option_inline_partials_at_compile_time = options[:inline_partials_at_compile_time]
    if @option_inline_partials_at_compile_time
      @partial_resolver = options[:partial_resolver]
      raise ArgumentError.new "Missing or invalid partial_resolver" unless @partial_resolver.respond_to? :call
    end

    # Initialize default tags
    self.otag ||= '{?' # Changed: Mustache defines these as '{{' and '}}'
    self.ctag ||= '}'
  end
end
