# Fix stupid form defaults
module ActionView
  module Helpers
    class InstanceTag
      DEFAULT_FIELD_OPTIONS = { }
      DEFAULT_TEXT_AREA_OPTIONS = { }
    end
  end
end
