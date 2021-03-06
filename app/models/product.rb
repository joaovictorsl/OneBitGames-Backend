class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :price, presence: true, numericality: {greater_than: 0}
  validates :description, presence: true
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_one_attached :image
  validates :image, presence: true
  validates :status, presence: true
  validates :featured, presence: true, if: -> {featured.nil?}

  enum status: {available: 1, unavailable: 2}

  include LikeSearchable
  include Paginatable
end
