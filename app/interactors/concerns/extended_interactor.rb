require 'ostruct'

##
# Requires +meets_conditions?+, +call+ and +description+ on the importing class.
#
# Maps call -> run (interactor default), check(!) -> check_context, describe(!) -> describe_action
#
# Automatically unpacks references and calls +meets_conditions?+, so check context.failure? immediately in call.
#
# (Note: all methods actually defined on interactors should be instance methods (def description) not class methods
# (def self.description). Trying to fit in with interactor magic in this file, and that kinda suits. Would also open
# possibilities about storing the _actual_ interactors (in another project)
#
#
# Sample content for a queueable interactor:
# include ExtendedInteractor
# queueable
#
# def call
#   after_check do
#
#   end
# end
#
# def check_context
#
# end
#
# def describe_action
#   "verb noun..."
# end
##

module ExtendedInteractor
  extend ActiveSupport::Concern

  included do
    include Interactor

    before :unpack_refs

    # Check to ensure the action can currently complete with the given context
    def self.check(context)
      new(context).tap(&:check).context
    end

    # Check to ensure the action can currently complete with the given context, and fail with an exception if conditions
    # are unmet
    def self.check!(context)
      new(context).tap(&:check!).context
    end

    # Run an action only if the action can currently complete with the given context
    def self.after_check(context, &block)
      instance = new(context)
      instance.after_check &block
      instance.context
    end

    # Run an action only if the action can currently complete
    def after_check
      result = check!
      yield if result.respond_to?(:success?) && result.success?
    rescue Interactor::Failure => _
    end

    # Check to ensure the action can currently complete
    def check
      check!
    rescue Interactor::Failure => _
      # Empty because we're assuming they'll inspect context
    end

    # Check to ensure the action can currently complete, and fail with an exception if conditions are unmet
    def check!
      with_hooks do
        check_context
      end
      context
    end

    private

    # Create a corresponding +var+ for every +var_ref+ variable
    def unpack_refs
      unwrapped = {}

      context.each_pair do |key, value|
        if key.to_s.ends_with?('_ref') && !(value.nil?)
          # Un-'ref'ify it
          unwrapped[key.to_s[0...-4]] = GlobalID::Locator.locate(value)
        end
      end

      unwrapped.each_key do |key|
        warn("Overwriting existing context parameter #{key.to_s} in #{self.class.name}") unless context[key].nil?
        context[key] = unwrapped[key]
      end
      context
    end

  end

end

