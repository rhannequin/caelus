# frozen_string_literal: true

class CreditsCatalog
  License = Data.define(:name, :url)

  MIT = License.new(
    name: "MIT",
    url: "https://opensource.org/license/mit"
  )
  BSD_3_CLAUSE = License.new(
    name: "BSD-3-Clause",
    url: "https://opensource.org/license/bsd-3-clause"
  )
  CC_BY_SA_4_0 = License.new(
    name: "CC BY-SA 4.0",
    url: "https://creativecommons.org/licenses/by-sa/4.0/"
  )
  RUBY_LICENSE = License.new(
    name: "Ruby licence",
    url: "https://www.ruby-lang.org/en/about/license.txt"
  )
  US_GOVERNMENT_PUBLIC_DOMAIN = License.new(
    name: "Public domain",
    url: "https://commons.wikimedia.org/wiki/Template:PD-USGov"
  )
  SQLITE_PUBLIC_DOMAIN = License.new(
    name: "Public domain",
    url: "https://sqlite.org/copyright.html"
  )

  Credit = Data.define(:key, :name, :url, :license)

  DATA = [
    Credit.new(
      key: :inpop19a,
      name: "INPOP19a",
      url: "https://www.imcce.fr/recherche/equipes/asd/inpop/download19a",
      license: nil
    ),
    Credit.new(
      key: :iers_bulletins,
      name: "IERS Earth orientation data",
      url: "https://www.iers.org",
      license: nil
    ),
    Credit.new(
      key: :clementine,
      name: "Clementine albedo mosaic",
      url: "https://commons.wikimedia.org/wiki/File:" \
        "Moonmap_from_clementine_data.png",
      license: US_GOVERNMENT_PUBLIC_DOMAIN
    ),
    Credit.new(
      key: :messier_catalog,
      name: "List of Messier objects",
      url: "https://en.wikipedia.org/wiki/List_of_Messier_objects",
      license: CC_BY_SA_4_0
    ),
    Credit.new(
      key: :ngc_catalog,
      name: "New General Catalogue",
      url: "https://en.wikipedia.org/wiki/New_General_Catalogue",
      license: CC_BY_SA_4_0
    )
  ].freeze

  SOFTWARE = [
    Credit.new(
      key: :astronoby,
      name: "Astronoby",
      url: "https://github.com/rhannequin/astronoby",
      license: MIT
    ),
    Credit.new(
      key: :ephem,
      name: "Ruby Ephem",
      url: "https://github.com/rhannequin/ruby-ephem",
      license: MIT
    ),
    Credit.new(
      key: :iers,
      name: "IERS",
      url: "https://github.com/rhannequin/iers",
      license: MIT
    ),
    Credit.new(
      key: :ruby,
      name: "Ruby",
      url: "https://www.ruby-lang.org/en/",
      license: RUBY_LICENSE
    ),
    Credit.new(
      key: :rails,
      name: "Ruby on Rails",
      url: "https://rubyonrails.org",
      license: MIT
    ),
    Credit.new(
      key: :hotwire,
      name: "Hotwire",
      url: "https://hotwired.dev",
      license: MIT
    ),
    Credit.new(
      key: :view_component,
      name: "ViewComponent",
      url: "https://viewcomponent.org",
      license: MIT
    ),
    Credit.new(
      key: :tailwindcss,
      name: "Tailwind CSS",
      url: "https://tailwindcss.com",
      license: MIT
    ),
    Credit.new(
      key: :propshaft,
      name: "Propshaft",
      url: "https://github.com/rails/propshaft",
      license: MIT
    ),
    Credit.new(
      key: :importmap_rails,
      name: "Importmap for Rails",
      url: "https://github.com/rails/importmap-rails",
      license: MIT
    ),
    Credit.new(
      key: :solid_queue,
      name: "Solid Queue",
      url: "https://github.com/rails/solid_queue",
      license: MIT
    ),
    Credit.new(
      key: :solid_cache,
      name: "Solid Cache",
      url: "https://github.com/rails/solid_cache",
      license: MIT
    ),
    Credit.new(
      key: :solid_cable,
      name: "Solid Cable",
      url: "https://github.com/rails/solid_cable",
      license: MIT
    ),
    Credit.new(
      key: :sqlite,
      name: "SQLite",
      url: "https://sqlite.org",
      license: SQLITE_PUBLIC_DOMAIN
    ),
    Credit.new(
      key: :puma,
      name: "Puma",
      url: "https://puma.io",
      license: BSD_3_CLAUSE
    ),
    Credit.new(
      key: :thruster,
      name: "Thruster",
      url: "https://github.com/basecamp/thruster",
      license: MIT
    ),
    Credit.new(
      key: :rack_attack,
      name: "Rack::Attack",
      url: "https://github.com/rack/rack-attack",
      license: MIT
    ),
    Credit.new(
      key: :kamal,
      name: "Kamal",
      url: "https://kamal-deploy.org",
      license: MIT
    ),
    Credit.new(
      key: :rspec,
      name: "RSpec",
      url: "https://rspec.info",
      license: MIT
    ),
    Credit.new(
      key: :standard,
      name: "Standard",
      url: "https://github.com/standardrb/standard",
      license: MIT
    )
  ].freeze

  SERVICES = [
    Credit.new(
      key: :appsignal,
      name: "AppSignal",
      url: "https://www.appsignal.com",
      license: nil
    ),
    Credit.new(
      key: :goatcounter,
      name: "GoatCounter",
      url: "https://www.goatcounter.com",
      license: nil
    )
  ].freeze

  def self.data
    DATA
  end

  def self.software
    SOFTWARE
  end

  def self.services
    SERVICES
  end
end
