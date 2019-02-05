//
//  Config.swift
//  verzity
//
//  Created by Jossue Betancourt on 18/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//
import UIKit

struct Config{
    
    static var config_data = "http://www.dwmedios.com/Apps/UrlAppVerzity2.json"
    //static var UID = UIDevice.current.identifierForVendor!.uuidString
    
    // Valores por default: Los valores se cargan de un Json en red, el cual si por alguna razon no carga bien tomara el valor de las siguientes variables
    static var desRutaWebServices = "http://verzity.dwmedios.com/WSPruebas/service/UNICONEKT.asmx/"
    static var desRutaMultimedia = "http://verzity.dwmedios.com/SITE/"
   
    
}

struct Strings {
    static var error_conexion = "Error de conexión"
}

final class Singleton {
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let shared = Singleton()
    
    //    Metodos de Webservice
    static let GetBecasVigentes = "GetBecasVigentes"
    static let GetCuponesVigentes = "GetCuponesVigentes"
    static let GetDetalleCupon = "GetDetalleCupon"
    static let IngresarAppUniversitario = "IngresarAppUniversitario"
    static let SolicitarFinanciamientos = "SolicitarFinanciamiento"
    static let GetFinanciamientosVigentes = "GetFinanciamientosVigentes"
    static let CrearCuentaAcceso = "CrearCuentaAcceso"
    static let IngresarAppUniversidad = "IngresarAppUniversidad"
    static let IngresarUniversitario = "IngresarAppUniversitario"
    static let GetDetallesUniversidad = "GetDetallesUniversidad"
    static let GetBannersVigentes = "GetBannersVigentes"
    static let RegistrarVisitaBanners = "RegistrarVisitaBanners"
    static let GetVideos = "GetVideos"
    static let PostularseBeca = "PostularseBeca"
    static let SetFavorito = "SetFavorito"
    static let RegistrarUniversidad = "RegistrarUniversidad"
    static let GetDetalleNotificacion = "GetDetalleNotificacion"
    static let CanjearCupon = "CanjearCupon"
    static let RecuperarContrasenia = "RecuperarContrasenia"
    static let GetPaquetesDisponibles = "GetPaquetesDisponibles"
    static let GetPaises = "GetPaises"
    static let BuscarCodigoPostal = "BuscarCodigoPostal"
    static let EditarPerfil = "EditarPerfil"
    static let PostularseUniversidad = "PostularseUniversidad"
    static let VerificarEstatusUniversidad = "VerificarEstatusUniversidad"
    static let VerificarFavorito = "VerificarFavorito"
    static let CerrarSesion = "cerrarSesion"
    static let verificarCuentaUniversitario = "verificarCuentaUniversitario"
    static let ActualizarCuentaUniversitario = "ActualizarCuentaUniversitario"
    static let subirImagen = "subirImagen"
    
    // Ws Nuevos y Actualizados
    static let CrearCuentaAccesoUniversitario = "CrearCuentaAccesoUniversitario"
    static let IngresarApp = "IngresarApp"
    static let GetAsesores = "GetAsesores"
    static let GetMisAsesores = "GetMisAsesores"
    static let GetPaquetesAsesoresDisponibles = "GetPaquetesAsesoresDisponibles"
    static let SaveVentaPaqueteAsesor = "SaveVentaPaqueteAsesor"
    static let RegistrarVisorBanners = "RegistrarVisorBanners"
    static let GetEstados = "GetEstados"
    
    //Programas Academicos
    static let GetNivelesAcademicos = "GetNivelesAcademicos"
    static let GetProgramasAcademicos = "GetProgramasAcademicos"
    
    
    
    static let ConsultarNotificacionesUniversitario = "ConsultarNotificacionesUniversitario"
    static let SaveVentaPaquete = "SaveVentaPaquete"
    static let GetPostulados = "GetPostulados"
    static let GetFavoritos = "GetFavoritos"
    static let ConsultarNotificaciones = "ConsultarNotificaciones"
    static let BusquedaUniversidades = "BusquedaUniversidades"
    static let getEvaluaciones = "getEvaluaciones"
    static let getResultado = "getResultado"
    static let getDetalleEvaluacion = "getDetalleEvaluacion"

    static let guardarRespuesta = "guardarRespuesta"
    static let ActrualizarStatusNotE = "ActrualizarStatusNotE"

    
}
