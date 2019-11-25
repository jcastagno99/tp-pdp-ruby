class Pirata

    def initialize (ebriedad)
        @cantidadMonedas = 0
        @items = []
        @invitante
        @nivelEbriedad = ebriedad
    end
    
   

    def items
        @items
    end

    def agregar_item!(unItem)
        @items.push(unItem)
    end

    def invitante
        @invitante
    end

    def nivelEbriedad
        @nivelEbriedad
    end

    def cantidadMonedas
        @cantidadMonedas
    end

    def tiene?(unItem)
        @items.include?(unItem)
    end

    def cantidad_items
        @items.size
    end

    def pasado_de_grog?
        @nivelEbriedad >= 90
    end

    def tomar_grog!
        @nivelEbriedad += 5
        self.gastar_moneda!
    end

    def gastar_moneda!
        self.validar_gastar_monedas!
        @cantidadMonedas -= 1
    end

    def validar_gastar_monedas!
        if @cantidadMonedas.equals?(0)
            raise "Cantidad de monedas insuficientes"
        end
    end

    def podes_saquear?(unaVictima)
        unaVictima.sos_saqueable_por?(self)
    end

    def cantidad_invitados_para(unBarco)
        unBarco.cantidad_invitados_por(self)
    end

    def fuiste_invitado_por?(unTripulante)
        @invitante.equals?(unTripulante)
    end
end

class PirataEspiaDeLaCorona < Pirata

    def pasado_de_grog?
        false
    end

    def podes_saquear(unaVictima)
        super && self.tiene?("permiso de la corona")
    end
end

class Barco 

    def initialize(unaMision, unaCapacidad)
        @tripulantes = []
        @mision = unaMision
        @capacidad = unaCapacidad
    end
    
    def tripulantes
        @tripulantes
    end

    def sos_saqueable_por?(unPirata)
        unPirata.pasado_de_grog?
    end

    def es_vulnerable_a?(otroBarco)
        self.cantidad_tripulantes <= otroBarco.cantidad_tripulantes / 2
    end

    def cantidad_tripulantes
        @tripulantes.size
    end

    def todos_pasados_de_grog?
        @tripulantes.all { |tripulante| tripulante.pasado_de_grog?}
    end

    def puede_unirse?(unPirata)
        self.hay_lugar? && @mision.es_util?(unPirata)
    end

    def hyar_lugar?
        self.cantidad_tripulantes < @capacidad
    end

    def agregar!(unTripulante)
        if self.puede_unirse?(unTripulante)
            @tripulantes.push(unTripulante)
        end
    end

    def cambiar_mision!(unaMision)
        @tripulantes.removeAllSuchThat { |tripulante| !unaMision.es_util?(tripulante)}
        @mision = unaMision
    end


    def pirata_mas_ebrio
        @tripulantes.max{ |tripulante| tripulante.nivelEbriedad}
    end

    def anclar_en!(unaCiudad)
        self.todos_toman_grog!
        self.perder_mas_ebrio_en!(unaCiudad)
    end

    def todos_toman_grog!
        @tripulantes.each {|tripulante| tripulante.tomar_grog!}
    end

    def perder_mas_ebrio_en!(unaCiudad)
        @tripulantes.delete(self.pirata_mas_ebrio)
        unaCiudad.sumar_habitante!
    end

    def es_temible?
        mision.es_realizable_por?(self)
    end

    def tiene_suficiente_tripulacion?
        self.cantidad_tripulantes >= @capacidad * 0.9
    end

    def tiene?(unItem)
        @tripulantes.any?{|tripulante| tripulante.tiene?(unItem)}
    end

    def tripulantes_pasados_de_grog
        @tripulantes.select{|tripulante| tripulante.pasado_de_grog?}
    end

    def cantidadTripulantesPasadosDeGrog
		self.tripulantes_pasados_de_grog.size
    end

    def cantidad_items_entre_tripulantes_pasados_de_grog
        self.tripulantes_pasados_de_grog.flat_map ({|tripulante| tripulante.items}).size
    end

    def tripulante_mas_invitador
        @tripulantes.max {|tripulante| tripulante.cantidad_invitados_para(self)}
    end

    def cantidad_invitados_por(unTripulante)
        @tripulantes.count {|tripulante| tripulante.fuiste_invitado_por?(unTripulante)}
    end
    
end


class Mision

    def es_realizable_por?(unBarco)
        unBarco.tiene_suficiente_tripulacion?
    end
end

class BusquedaDelTesoro < Mision

    def es_util?(unPirata)
        self.tiene_algun_item_obligatorio?(unPirata) && unPirata.cantidadMonedas <= 5
    end

    def tiene_algun_item_obligatorio?(unPirata)
        ["brujula","mapa","grogXD"].any?{ |item| unPirata.tiene?(item)}
    end

    def es_realizable_por?(unBarco)
        super && unBarco.tiene?("llave de cofre")
    end
end

class ConvertirseEnLeyenda < Mision
    def initialize(unItem)
        @itemObligatorio = unItem
    end

    def es_util?(unPirata)
        unPirata.cantidad_items >= 10 && unPirata.tiene?(@itemObligatorio)
    end
end

class Saqueo < Mision
    
    def initialize(unaVictima)
        @victima = unaVictima
    end

    def es_util?(unPirata)
        unPirata.cantidadMonedas < monedasParaSaquear.limite && @victima.sos_saqueable_por?(unPirata)
    end

    def es_realizable_por?(unBarco)
        super && @vitcima.es_vulnerable_a?(unBarco)
    end

end

module MonedasParaSaquear

    def initialize
        @limite = 0
    end

    def self.limite
        @limite
    end
end

class CiudadCostera

    def initialize(unaCantidad)
        @cantidadHabitantes = unaCantidad
    end

    def cantidadHabitantes
        @cantidadHabitantes
    end

    def sos_saqueable_por?(unPirata)
        unPirata.nivelEbriedad >= 50
    end

    def es_vulnerable_a?(otroBarco)
        otroBarco.cantidad_tripulantes >= @cantidadHabitantes * 0.4 || otroBarco.todos_pasados_de_grog?
    end

    def sumar_habitante!
        @cantidadHabitantes += 1
    end
end