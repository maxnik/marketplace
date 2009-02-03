class DivedBuilder < ActionView::Helpers::FormBuilder

  %w(text_field password_field text_area).each do |field_type|
    define_method("#{field_type}_for") do |attr, *args|

      options = {}
      options.merge!(args.last) if args.last.is_a?(Hash)
      options[:default]    ||= @object.send(attr) unless @object.nil?
      options[:label]      ||= "Название поля"            # field_label
      options[:bottom]     ||= "&nbsp;"                   # bottom_span
      options[:param_name] ||= "#{@object_name}[#{attr}]" # param_name

      error = @object.nil? ? options[:error] : @object.errors.on(attr.to_s)
      bottom_span_class, field_class = error ? ['error', 'error-field'] : ['text', 'text-field']
      options[:bottom] = error if error

      @template.content_tag(:div, :id => options[:div_id], :style => options[:div_style]) do 
        @template.content_tag(:label, :for => attr.to_s) do 
          @template.content_tag(:span) { options[:label] }
        end +
        @template.content_tag(:p) do 
          @template.send("#{field_type}_tag".to_sym, options[:param_name], 
                         options[:default], :class => field_class) +
          @template.content_tag(:span, :class => bottom_span_class) { options[:bottom] }
        end
      end
    end
  end

  def check_box_for(attr, *args)

    options = {}
    options.merge!(args.last) if args.last.is_a?(Hash)
    options[:default]    ||= false
    options[:param_name] ||= "#{@object_name}[#{attr}]"
    options[:label]      ||= "название поля"
    
    @template.content_tag(:div, :class => 'checkbox-div') do 
      @template.send(:check_box_tag, options[:param_name], '1', options[:default], :class => 'checkbox') +
      @template.content_tag(:span) { options[:label] }
    end
  end

  def submit_tag(value)
    @template.content_tag(:div) do 
      @template.content_tag(:input, nil, :type => 'submit', :class => 'button', :value => value)
    end
  end

end
