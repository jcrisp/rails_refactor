# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails_refactor}
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Crisp & Ryan Bigg"]
  s.date = %q{2011-05-02}
  s.default_executable = %q{rails_refactor}
  s.description = %q{Simple refactoring like rename class for Rails projects}
  s.email = %q{james@crispdesign.net}
  s.executables = ["rails_refactor"]
  s.extra_rdoc_files = ["CHANGELOG", "README", "bin/rails_refactor", "lib/rails_refactor.rb"]
  s.files = ["CHANGELOG", "Gemfile", "Gemfile.lock", "Manifest", "README", "Rakefile", "bin/rails_refactor", "dummy/Gemfile", "dummy/Gemfile.lock", "dummy/README", "dummy/Rakefile", "dummy/app/controllers/application_controller.rb", "dummy/app/controllers/dummies_controller.rb", "dummy/app/helpers/application_helper.rb", "dummy/app/helpers/dummies_helper.rb", "dummy/app/models/dummy_model.rb", "dummy/app/views/dummies/index.html.erb", "dummy/app/views/layouts/application.html.erb", "dummy/autotest/discover.rb", "dummy/config.ru", "dummy/config/application.rb", "dummy/config/boot.rb", "dummy/config/database.yml", "dummy/config/environment.rb", "dummy/config/environments/development.rb", "dummy/config/environments/production.rb", "dummy/config/environments/test.rb", "dummy/config/initializers/backtrace_silencers.rb", "dummy/config/initializers/inflections.rb", "dummy/config/initializers/mime_types.rb", "dummy/config/initializers/secret_token.rb", "dummy/config/initializers/session_store.rb", "dummy/config/locales/en.yml", "dummy/config/routes.rb", "dummy/db/migrate/20101230081247_create_dummy_models.rb", "dummy/db/seeds.rb", "dummy/doc/README_FOR_APP", "dummy/public/404.html", "dummy/public/422.html", "dummy/public/500.html", "dummy/public/favicon.ico", "dummy/public/images/rails.png", "dummy/public/index.html", "dummy/public/javascripts/application.js", "dummy/public/javascripts/controls.js", "dummy/public/javascripts/dragdrop.js", "dummy/public/javascripts/effects.js", "dummy/public/javascripts/prototype.js", "dummy/public/javascripts/rails.js", "dummy/public/robots.txt", "dummy/script/rails", "dummy/spec/controllers/dummies_controller_spec.rb", "dummy/spec/helpers/dummies_helper_spec.rb", "dummy/spec/models/dummy_model_spec.rb", "dummy/spec/spec_helper.rb", "dummy/test/functional/dummies_controller_test.rb", "dummy/test/performance/browsing_test.rb", "dummy/test/test_helper.rb", "dummy/test/unit/helpers/dummies_helper_test.rb", "lib/rails_refactor.rb", "rails_refactor.gemspec"]
  s.homepage = %q{https://github.com/jcrisp/rails_refactor}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rails_refactor", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rails_refactor}
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{Simple refactoring like rename class for Rails projects}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
