class Review < ApplicationRecord
  belongs_to :item
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :score
end
