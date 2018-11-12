import RealmSwift
import Foundation


class Usuario: Object {
    @objc dynamic var idUsuario = 0
    @objc dynamic var idPersona = 0
    @objc dynamic var idPerfil = 0
    
    @objc dynamic var nbUsuario = ""
    @objc dynamic var pwdContrasenia = ""
    @objc dynamic var idEstatus = ""
    @objc dynamic var cvFacebook = ""
    
    @objc dynamic var Persona: Persona?
}

class Persona: Object {
    @objc dynamic var idPersona = 0
    @objc dynamic var idDireccion = 0
    @objc dynamic var idTipoPersona = 0
    
    @objc dynamic var nbCompleto = ""
    @objc dynamic var desTelefono = ""
    @objc dynamic var desCorreo = ""
    @objc dynamic var pathFoto = ""
    @objc dynamic var desSkype = ""
    @objc dynamic var desPersona = ""
    
    @objc dynamic var Direcciones: Direcciones?
    @objc dynamic var Dispositivos: Dispositivos?
    @objc dynamic var VestasPaquetesAsesores: VestasPaquetesAsesores?
    @objc dynamic var Universidades: Universidades?
}

class Direcciones: Object {
    @objc dynamic var idDireccion = 0
    
    @objc dynamic var desDireccion = ""
    @objc dynamic var numCodigoPostal = ""
    @objc dynamic var nbPais = ""
    @objc dynamic var nbEstado = ""
    @objc dynamic var nbMunicipio = ""
    @objc dynamic var nbCiudad = ""
    @objc dynamic var dcLatitud = ""
    @objc dynamic var dcLongitud = ""
}


class Dispositivos: Object {
    @objc dynamic var idDispositivo = 0
    @objc dynamic var idPersona = 0
    
    @objc dynamic var cvDispositivo = ""
    @objc dynamic var cvFirebase = ""
}

class VestasPaquetesAsesores: Object {
    @objc dynamic var idVentaPaqueteAsesor = 0
    @objc dynamic var idPaqueteAsesor = 0
    @objc dynamic var idPersona = 0
    @objc dynamic var idPersonaAsesor = 0
    
    @objc dynamic var feVenta = ""
    @objc dynamic var feVigencia = ""
    @objc dynamic var fgPaqueteActual = ""
    @objc dynamic var numReferenciaPaypal = ""
    @objc dynamic var numLiberados = ""
    @objc dynamic var numUsados = ""
    
}

class Universidades: Object {
    @objc dynamic var idUniversidad = 0
    @objc dynamic var idEstatus = 0
    @objc dynamic var idDireccion = 0
    @objc dynamic var idPersona = 0

    
    @objc dynamic var pathLogo = ""
    @objc dynamic var nbUniversidad = ""
    @objc dynamic var nbReprecentante = ""
    @objc dynamic var desUniversidad = ""
    @objc dynamic var desSitioWeb = ""
    @objc dynamic var desTelefono = ""
    @objc dynamic var desCorreo = ""
    @objc dynamic var feRegistro = ""
    
  
    @objc dynamic var urlFolletosDigitales = ""
    @objc dynamic var urlFaceBook = ""
    @objc dynamic var urlTwitter = ""
    @objc dynamic var urlInstagram = ""
    
    @objc dynamic var Direcciones: Direcciones?
    @objc dynamic var VestasPaquetes: VestasPaquetes?
    
}


class VestasPaquetes: Object {
    @objc dynamic var idVentasPaquetes = 0
    @objc dynamic var idUniversidad = 0
    @objc dynamic var idPaquete = 0
    
    @objc dynamic var feVenta = ""
    @objc dynamic var feVigencia = ""
    @objc dynamic var fgPaqueteActual = ""
    @objc dynamic var fgRecurrente = ""
    @objc dynamic var numReferenciaPaypal = ""
    
    @objc dynamic var Paquete: Paquete?
}

class Paquete: Object {
    @objc dynamic var idPaquete = 0
    @objc dynamic var idEstatus = 0

    @objc dynamic var cvPaquete = ""
    @objc dynamic var nbPaquete = ""
    @objc dynamic var desPaquete = ""
    @objc dynamic var dcDiasVigencia = ""
    
    @objc dynamic var fgAplicaBecas = ""
    @objc dynamic var fgAplicaFinanciamiento = ""
    @objc dynamic var fgAplicaPostulacion = ""
    @objc dynamic var fgAplicaProspectus = ""
    
    @objc dynamic var fgAplicaLogo = ""
    @objc dynamic var fgAplicaDireccion = ""
    @objc dynamic var fgAplicaFavoritos = ""
    @objc dynamic var fgAplicaUbicacion = ""
    @objc dynamic var fgAplicaRedes = ""
    @objc dynamic var fgAplicaProspectusVideo = ""
    @objc dynamic var fgAplicaProspectusVideos = ""
    @objc dynamic var fgAplicaAplicaImagenes = ""
    @objc dynamic var fgAplicaContacto = ""
    @objc dynamic var fgAplicaDescripcion = ""
    
}
