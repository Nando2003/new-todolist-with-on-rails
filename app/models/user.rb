class User < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :password_digest, presence: true
end
