class Job < ApplicationRecord

  validates_presence_of :title, :company
end