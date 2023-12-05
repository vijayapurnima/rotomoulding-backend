module Contextual

  def self.included(base)
    base.send(:before, :unwrap_references)
  end

  def unwrap_references
    unwrapped = {}

    context.each_pair do |key,value|
      if key.to_s.ends_with?('_ref') && !(value.nil?)
        # Un-'ref'ify it
        unwrapped[key.to_s[0...-4]] = GlobalID::Locator.locate(value)
      end
    end

    unwrapped.each_key do |key|
      warn("Overwriting existing context parameter #{key.to_s}") unless context[key].nil?
      context[key] = unwrapped[key]
    end
  end

  def before_description(context)
    unwrapped = {}

    context.each_pair do |key,value|
      if key.to_s.ends_with?('_ref') && !(value.nil?)
        # Un-'ref'ify it
        unwrapped[key.to_s[0...-4]] = GlobalID::Locator.locate(value)
      end
    end

    unwrapped.each_key do |key|
      warn("Overwriting existing context parameter #{key.to_s}") unless context[key].nil?
      context[key] = unwrapped[key]
    end
  end

end
