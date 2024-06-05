# Thoran/File/SelfCollect/self.collect.rb
# Thoran::File::SelfCollect.collect.rb

# 20190821
# 0.2.0

# Changes:
# 1. + Thoran::File::SelfCollect namespace.

module Thoran
  module File
    module SelfCollect
      
      def collect(filename, &block)
        open(filename, 'r').collect(&block)
      end
      
    end
  end
end

File.extend(Thoran::File::SelfCollect)
