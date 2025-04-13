class Category < ApplicationRecord
  has_many :metrics, dependent: :destroy

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-]+\z/, message: "は英数字とハイフンのみ使用できます" }
end
