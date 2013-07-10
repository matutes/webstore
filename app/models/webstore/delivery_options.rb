require_relative 'form'
require_relative '../webstore'
require_relative '../../decorators/webstore/route_decorator'

class Webstore::DeliveryOptions < Webstore::Form
  attribute :cart
  attribute :route
  attribute :start_date,       Date
  attribute :frequency,        String
  attribute :days,             Hash[Integer => Integer]
  attribute :extra_frequency,  Boolean

  def existing_route_id
    customer.route_id
  end

  def can_change_route?
    !!existing_route_id
  end

  def routes
    distributor_routes = distributor.routes
    Webstore::RouteDecorator.decorate_collection(distributor_routes)
  end

  def route_list
    distributor.routes.map { |route| route_list_item(route) }
  end

  def order_frequencies
    #ScheduleRule::RECUR.map { |frequencies| [frequencies.to_s.titleize, frequencies.to_s] }
    [
      ['Deliver weekly on...', :weekly],
      ['Deliver every 2 weeks on...', :fortnightly],
      ['Deliver monthly', :monthly],
      ['Deliver once', :single]
    ]
  end

  def extra_frequencies
    [
      ['Include Extra Items with EVERY delivery', false],
      ['Include Extra Items with NEXT delivery only', true]
    ]
  end

  def dates_grid
    ::Order.dates_grid
  end

  def start_dates(route)
    ::Order.start_dates(route)
  end

  def cart_has_extras?
    #webstore_order.box.extras_allowed? && webstore_order.extras.present?
    true
  end

  def to_h
    {
      route_id:         route,
      start_date:       start_date,
      frequency:        frequency,
      days:             days,
      extra_frequency:  extra_frequency,
    }
  end

private

  def distributor
    cart.distributor
  end

  def customer
    cart.customer
  end

  def route_list_item(route)
    [ route.name_days_and_fee, route.id ]
  end
end
