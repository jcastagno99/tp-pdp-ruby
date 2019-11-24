require_relative "CODE"
require "test/unit"

class TestPiratandeah < Test::Unit::TestCase


def test_pasadoGrog
    elSulo = Pirata.new(100)
    puts "El pirata #{elSulo.nivelEbriedad} "
end

end