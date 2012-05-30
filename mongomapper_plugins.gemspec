Gem::Specification.new do |s|
  s.name = %q{mongomapper_plugins}
  s.version = File.read('VERSION')

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Timberlake"]
  s.date = %q{2011-02-28}
  s.description = %q{A repository of MongoMapper plugins.}
  s.summary = %q{A repository of MongoMapper plugins.}
  s.email = %q{andrew@andrewtimberlake.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
  ] + Dir['lib/**/*.rb']
  s.homepage = %q{http://github.com/andrewtimberlake/mongomapper_plugins}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}

  if s.respond_to? :specification_version
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 1.0"])
    else
      s.add_dependency(%q<bundler>, [">= 1.0"])
      s.add_dependency(%q<mongo_mapper>, [">= 0.11.1"])
    end
  else
    s.add_dependency(%q<mongo_mapper>, [">= 0.11.1"])
  end
end
