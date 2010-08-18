module Porm
  class CreateSuccessProxy
    def initialize(object)
      @object = object
    end
    def on_success(block)
      block.call @object
      self
    end

    def on_failure(block)
      self
    end
  end
end
