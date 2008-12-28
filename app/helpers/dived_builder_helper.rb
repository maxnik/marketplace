module DivedBuilderHelper
  def dived_form_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:builder => DivedBuilder)
    args <<= options
    form_for(name, *args, &block)
  end
end
