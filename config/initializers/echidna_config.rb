#require 'activerecord-import'
require 'ar-extensions'

ECHIDNA_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/echidna.yml")[RAILS_ENV]
