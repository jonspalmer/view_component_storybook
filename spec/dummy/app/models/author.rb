# frozen_string_literal: true

class Author
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :first_name, :string
  attribute :last_name, :string

  def full_name
    "#{first_name} #{last_name}"
  end
end
