require 'spec_helper'
require 'users'

describe Users::Client do
  let(:client) { described_class.new('api_key', 'http://host') }

end
