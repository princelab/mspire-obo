module Obo
  class Stanza

    def cast_method
      xref = @tagvalues['xref'].first
      @cast_method = 
        if xref.nil? || (@cast_method == false)
          false
        else
          if @cast_method
            @cast_method
          else
            case xref[/value-type:xsd\\:([^\s]+) /, 1]
            when 'float'  ; :to_f
            when 'int'    ; :to_i
            when 'string' ; :to_s
            else          ; false
            end
          end
        end
    end

    # returns the value cast based on rules in first xref
    # no casting performed if there is no xref
    def cast(val)
      @cast_method ? val.send(@cast_method) : val
    end
  end
end
