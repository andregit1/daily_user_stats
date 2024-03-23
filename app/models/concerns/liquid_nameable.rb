require 'liquid'

module LiquidNameable
  extend ActiveSupport::Concern

  def liquid_name
    template = Liquid::Template.parse("{{ name['title'] }} {{ name['first'] }} {{ name['last'] }}")
    template.render('name' => name)
  end
end
