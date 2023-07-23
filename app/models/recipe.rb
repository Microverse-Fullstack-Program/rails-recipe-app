class Recipe < ApplicationRecord
  include Visible

  belongs_to :user
  has_many :recipe_foods, foreign_key: 'recipe_id' # Update the foreign key here
  has_many :foods, through: :recipe_foods

  validates :name, presence: true
  validates :cooking_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :preparation_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :description, presence: true
end
