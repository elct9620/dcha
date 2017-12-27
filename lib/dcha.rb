require 'oj'
require 'rlp'
require 'digest'
require 'socket'
require 'ipaddr'
require 'singleton'

require 'dcha/version'

# :nodoc:
module Dcha
  autoload :Config, 'dcha/config'
  autoload :MPT, 'dcha/mpt'
  autoload :UI, 'dcha/ui'
  autoload :Peer, 'dcha/peer'
end
