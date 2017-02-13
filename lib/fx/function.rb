module Fx
  # @api private
  class Function
    DEFAULT_ARGUMENT = "()"

    include Comparable

    attr_reader :name, :definition, :arguments
    delegate :<=>, to: :name

    def initialize(function_row)
      @name = function_row.fetch("name")
      @definition = function_row.fetch("definition")
      @arguments = function_row["arguments"].presence || DEFAULT_ARGUMENT
    end

    def signature
      "#{name}#{arguments}"
    end

    def ==(other)
      name == other.name && definition == other.definition
    end

    def to_schema
      <<-SCHEMA.indent(2)
create_function :#{name}, sql_definition: <<-\SQL
#{definition.indent(4).rstrip}
SQL
      SCHEMA
    end
  end
end
