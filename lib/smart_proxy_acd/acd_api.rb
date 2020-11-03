require 'sinatra'
require 'smart_proxy_acd/acd'
require 'smart_proxy_acd/acd_main'

module Proxy::Acd

  class Api < ::Sinatra::Base
    include ::Proxy::Log
    helpers ::Proxy::Helpers

    get '/hello' do
      Proxy::Acd.say_hello
    end

    get '/playbooks' do
      Proxy::Acd.read_playbooks
    end

    get '/playbook_variables' do
      Proxy::Acd.read_playbook_vars
    end
  end
end
