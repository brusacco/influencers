class InstagramCollaboration < ApplicationRecord
  belongs_to :instagram_post
  belongs_to :collaborator, class_name: 'Profile'
  belongs_to :collaborated, class_name: 'Profile'
end
