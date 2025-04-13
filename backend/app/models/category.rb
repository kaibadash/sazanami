# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :metrics, dependent: :destroy

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-]+\z/ }
end
