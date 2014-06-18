require 'hashie'

class YAMLHash < Hashie::Mash

#  def initialize (arg=nil)
#    super
#    if !arg.nil? 
#      self.load(arg)
#    end
#  end

  def load_file fs
    f = File.open(fs, "rt")
    self.load f.read
    f.close
  end

  def load s
    lin = s.lines
    stack = Array.new
    while (true) do
      begin 
        line = lin.next
      rescue
        break
      end

      currentDepth = line.scan(/^\s*/).first.length / 2
      while (currentDepth) < stack.length
        stack.pop
      end

      stack.push(line.lstrip.chomp)
      self[stack] = nil
    end
  end
end
