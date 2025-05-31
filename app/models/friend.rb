# app/models/friend.rb
class Friend < ApplicationRecord
  belongs_to :user
end
