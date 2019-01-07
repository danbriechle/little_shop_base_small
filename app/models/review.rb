class Review < ApplicationRecord
  belongs_to :item
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :score
  validates :score, inclusion: {in: [1,2,3,4,5]}
end
