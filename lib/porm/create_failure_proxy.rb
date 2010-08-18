module Porm
  class CreateFailureProxy
    def initialize(object)
      @object = object
    end
    def on_success(block)
      self
    end

    def on_failure(block)
      block.call @object
      self
    end
  end
end
