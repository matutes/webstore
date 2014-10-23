require_relative '../form'

class CustomiseOrder < Form
  attribute :has_customisations,  Boolean
  attribute :dislikes,            Array[Integer]
  attribute :likes,               Array[Integer]
  attribute :extras,              Hash[Integer => Integer]
  attribute :add_extra,           Boolean

  validate :validate_number_of_exclusions
  validate :validate_number_of_substitutions
  validate :validate_number_of_extras

  delegate :stock_list, to: :cart

  delegate :extras_list, to: :cart

  def exclusions?
    product.dislikes
  end

  def substitutions?
    product.likes
  end

  def extras_allowed?
    product.extras_allowed
  end

  def extras_unlimited?
    product.extras_unlimited
  end

  delegate :exclusions_limit, to: :product

  def exclusions_unlimited?
    product.exclusions_unlimited
  end

  delegate :substitutions_limit, to: :product

  def substitutions_unlimited?
    product.substitutions_unlimited
  end

  delegate :extras_limit, to: :product

  def to_h
    {
      dislikes:  dislikes,
      likes:     likes,
      extras:    extras,
    }
  end

protected

  def sanitize_attributes(attributes)
    attributes.fetch("dislikes", []).delete("")
    attributes.fetch("likes", []).delete("")
    attributes.fetch("extras", {}).delete_if do |_key, value|
      value = value.to_i
      value <= 0 || value > max_line_items_count
    end

    attributes
  end

  def product
    cart.product
  end

  def exclusions_count
    dislikes.size || 0
  end

  def substitutions_count
    likes.size || 0
  end

  def extras_count
    extras.values.reduce(:+) || 0
  end

private

  def validate_number_of_exclusions
    validate_number_of(:exclusions)
  end

  def validate_number_of_substitutions
    validate_number_of(:substitutions)
  end

  def validate_number_of_extras
    validate_number_of(:extras)
  end

  def validate_number_of(items)
    items_count     = send("#{items}_count")
    items_unlimited = send("#{items}_unlimited?")
    items_limit     = send("#{items}_limit")

    if !items_unlimited && items_count > items_limit
      errors.add(items, "you have too many #{items}, the maximum is #{items_limit}")
    end
  end

  def max_line_items_count
    1000
  end
end
