# app/helpers/storage_helper.rb

module StorageHelper
  def direct_storage_url(key)
    # Assuming the key is something like "m4vk797r3w74pvu3m98gt3wctus0"
    # and the storage structure is "m4/vk/797r3w74pvu3m98gt3wctus0"
    # Adjust the slicing as per your storage structure
    dir1 = key[0..1]
    dir2 = key[2..3]
    filename = key[4..]

    # Construct the URL
    "https://www.influencers.com.py/storage/#{dir1}/#{dir2}/#{filename}"
  end
end
