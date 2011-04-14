require 'active_support/ordered_hash'

module ActiveSupport
  class OrderedHash
    alias :zero? :blank?
  end
end
