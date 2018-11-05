//
//  Strings.swift
//  verzity
//
//  Created by Jossue Betancourt on 05/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import Foundation


class StringsLabel{
    
    
    // General
    static let timeCancelPay : Double = 60.0
    static let url_imagen_mapa = "http://maps.google.com/maps/api/staticmap?center=%d,%d&zoom=15&size=300x300&markers=color:red|%d,%d"
    static let operation_complete = "Operación realizada con éxito"
    static let upload_image = "Imagen cargada con éxito"

    static let account_invalid = "La información de la universidad está siendo validada por el administrador, se le notificará por correo electrónico cuando el proceso concluya."
    
    static let cancel_buy = "No podrá gozar los beneficios de VERZITY hasta que realice la adquisición de un paquete."
    // Patrones
    static let numero_letra = "AÁÀÄÂÃÅĄÆĀªaáàäâãåąæāªBbCÇĆČcçćčDĐdđEÉÈËÊĘĖĒeéèëêęėēFfGgHhĪĮÎÌÏÍIiíïìîįīIJjKkLlMmNŃnńÓOÒÖÔÕØŒŌºoóòöôõøœōºPpQqRrSŠsšTtUÚÜÙÛŪuúüùûūVvWwXxYyZz0123456789 "
    static let letras = "AÁÀÄÂÃÅĄÆĀªaáàäâãåąæāªBbCÇĆČcçćčDĐdđEÉÈËÊĘĖĒeéèëêęėēFfGgHhĪĮÎÌÏÍIiíïìîįīIJjKkLlMmNŃnńÓOÒÖÔÕØŒŌºoóòöôõøœōºPpQqRrSŠsšTtUÚÜÙÛŪuúüùûūVvWwXxYyZz "
    static let correo = "AÁÀÄÂÃÅĄÆĀªaáàäâãåąæāªBbCÇĆČcçćčDĐdđEÉÈËÊĘĖĒeéèëêęėēFfGgHhĪĮÎÌÏÍIiíïìîįīIJjKkLlMmNŃnńÓOÒÖÔÕØŒŌºoóòöôõøœōºPpQqRrSŠsšTtUÚÜÙÛŪuúüùûūVvWwXxYyZz0123456789_.@-"
    static let numeros = "0123456789"
  
    
    // Validacion de datos de Formularios
    static let required = "Campo requerido."
    static let phone_invalid = "Ingrese un número de teléfono valido."
    static let email_invalid = "Ingrese un correo electrónico valido."
    static let acept_invalid = "Debe estar de acuerdo con los términos."
    static let password_coinciden_invalid = "La contraseña y la confirmación no coinciden."
    static let password_invalid = "La contraseña debe tener como mínimo 8 caracteres de longitud."

    // Errores
    static let error_conexion = "Ocurrio un error al establecer contacto con el servidor. Favor de verificar su conexión a internet"
    
    // Defaul Valores
    static let no_university_name = "dw medios"
    static let no_address = "No se encontró dirección"
    static let no_phone = "No se encontró número telefónico"
    static let no_website = "http://www.dwmedios.com"
    static let no_email = "contactanos@dwmedios.com"

    
}
