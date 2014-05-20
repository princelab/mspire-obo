require 'mspire/obo'

Mspire::Obo::MS = Mspire::Obo.create(

      def initialize(read_obo=false)
        info = INFO.dup
        obo = info.delete(:obo)
        super( read_obo ? Mspire::Obo::DIR + "/#{obo}" : nil, *info )
      end
    end
  end
end


