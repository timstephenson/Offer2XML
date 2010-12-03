#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'offer'

from_file = ARGV[0]
to_file = ARGV[1]


offers = Offer.parse_csv_file(from_file)

Offer.xml(offers, to_file)