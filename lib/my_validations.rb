module MyValidations

  module ClassMethods
    [:validates_presence_of, 
     :validates_length_of,
     :validates_numericality_of,
     :validates_uniqueness_of,
     :validates_format_of].each do |method|
      eval <<-eos
      def my_#{method}(field, args = {})
        args.update(:if => Proc.new {|model| model.errors.on(field).blank? })
        #{method}(field, args)
      end
      eos
    end 
  end
  
  def self.included(receiver)
    receiver.extend(ClassMethods)
  end
end
