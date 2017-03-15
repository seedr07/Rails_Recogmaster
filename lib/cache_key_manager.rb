# module HashKey
# The purpose of this module is to manage keys that can be used
# as a key to caching objects.  
# The idea here is to use a key that has a unique hashed identifier
# appended to it so that we can invalidate the key at any time.
# To invalidate a key, all you need to do
# is tell it to update(via touch), and the key will be reset so that
# when an object is attempted to be fetched, the key will now be updated
# and the cache will be refreshed automagically
#
# Example:
#  
#           # first attempt here will generate a unique cache lookup key for this attribute,
#           # it will have SecureRandom.hex component.  This key is itself cached which has
#           # a reliable lookup key that is unique to the Class:Id:Attribute
#           # Therefore we return a unique but consistent lookup key for this attribute on 
#           # a particular object
#           Rails.cache.fetch(ckm_cache_key(:attribute)) do
#             self.go_get_value_for_attribute_that_you_want_to_cache
#           end
#
#           # All we need to do is invalidate the cache by invalidating the unique cache key, 
#           # thus next fetch will get a miss on the key and cache a new value
#           ckm_touch(:attribute)
#
module CacheKeyManager
  PREFIX = "CacheKey"
  module ClassMethods
    def ckm_cache_key(key)
      Rails.cache.fetch(CacheKeyManager.ckm_lookup_key(self, key)) do 
        CacheKeyManager.ckm_unique_key(self, key)
      end
    end

    def ckm_touch(key)
      Rails.cache.write(CacheKeyManager.ckm_lookup_key(self, key), CacheKeyManager.ckm_unique_key(self, key))
    end

    def ckm_cache_key_timestamp(key)
      CacheKeyManager.cache_key_timestamp(ckm_cache_key(key))
    end

  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  # instance methods
  def ckm_cache_key(key)
    Rails.cache.fetch(CacheKeyManager.ckm_lookup_key(self, key)) do 
      CacheKeyManager.ckm_unique_key(self, key)
    end
  end

  def ckm_touch(key)
    Rails.cache.write(CacheKeyManager.ckm_lookup_key(self, key), CacheKeyManager.ckm_unique_key(self, key))
  end
  
  def ckm_cache_key_timestamp(key)
    CacheKeyManager.cache_key_timestamp(ckm_cache_key(key))
  end

  # Static module methods
  def self.ckm_lookup_key(object, key)
    return "#{PREFIX}-#{object.ckm_lookup_key(key)}" if object.respond_to?(:ckm_lookup_key)

    # use 'CacheKey' as a namespace to have minimal conflicts
    if object.respond_to?(:id)
      "#{PREFIX}-#{object.class.to_s}-#{object.id}-#{key}"
    else
      "#{PREFIX}-#{object.class.to_s}-#{key}"
    end
  end

  def self.ckm_unique_key(object, key)
    "#{CacheKeyManager.ckm_lookup_key(object, key)}-#{CacheKeyManager.ckm_unique_value}"
  end

  def self.ckm_unique_value
    "["+Time.now.to_i.to_s+":"+SecureRandom.hex+"]"
  end
  
  def self.cache_key_timestamp(key)
    key.match(/\[(.*):.*\]/)[1]
  end

  def self.clear
    Rails.cache.delete_matched(PREFIX)
  end

end