class Metric < ApplicationRecord
  belongs_to :category
  has_many :metric_values, dependent: :destroy

  before_save :set_default_label

  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\-]+\z/, message: "は英数字とハイフンのみ使用できます" }
  validates :unit, presence: true
  validates :prefix_unit, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :category_id }

  private

  def set_default_label
    self.label = name if label.blank?
  end
end
