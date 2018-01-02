require 'oj'
require 'rlp'
require 'digest'
require 'socket'
require 'ipaddr'
require 'singleton'
require 'curses'

require 'dcha/version'

# :nodoc:
module Dcha
  autoload :Config, 'dcha/config'
  autoload :MPT, 'dcha/mpt'
  autoload :UI, 'dcha/ui'
  autoload :Peer, 'dcha/peer'
  autoload :Chunk, 'dcha/chunk'
  autoload :PacketManager, 'dcha/packet_manager'
end
