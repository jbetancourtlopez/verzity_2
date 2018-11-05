//
//  Menus.swift
//  verzity
//
//  Created by Jossue Betancourt on 21/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit

struct Menus{
  
    static let menu_main_university = [
        [
            "name":"Paquetes",
            "image":"ic_comprar_paquete",
            "type": "package",
             "color": "#ff7b25"
        ],
        [
            "name":"Postulados",
            "image":"ic_mortarboard",
            "type": "postulate",
            "color": "#1d47f1"
        ],
       
        
    ]
    
    static let menu_main_academic = [
        [
            "name":"Buscar universidades",
            "image":"ic_searc_right.png",
            "type": "find_university",
            "color": "#388E3C"
            
        ],
        [
            "name":"Financiamiento",
            "image":"ic_action_financiamiento.png",
            "type": "financing",
            "color": "#ff7b25"
        ],
        [
            "name":"Cupones y descuentos",
            "image":"ic_ticket",
            "type": "coupons",
            "color": "#F7BF25"
        ],
        [
            "name":"Becas",
            "image":"ic_action_ic_openbook.png",
            "type": "becas",
            "color": "#32cb00"
        ],

        
    ]
    
    static let menu_find_university = [
        [
            "name":"Universidad",
            "image":"ic_action_ic_school.png",
            "type": "find_university",
            "color": "#388E3C"
        ],
        [
            "name":"Programas académicos",
            "image":"ic_mortarboard.png",
            "type": "find_academics",
            "color": "#1d47f1"
        ],
        [
            "name":"Cerca de mi",
            "image":"ic_gps.png",
            "type": "find_next_to_me",
            "color": "#ff0106"
        ],
        [
            "name":"En EE. UU.",
            "image":"ic_action_aeroplane.png",
            "type": "find_euu",
            "color": "#b47102"
        ],
        [
            "name":"Favoritos",
            "image":"ic_action_star_border.png",
            "type": "find_favorit",
            "color": "#F7BF25"
        ]
        
    ]
    
    static let side_menu_university = [
        [],
        [
            "name":"Inicio",
            "image":"ic_action_ic_home.png",
            "type": "home_university"
        ],
        [
            "name":"Ver Perfil universitario",
            "image":"ic_action_ic_school.png",
            "type": "profile_academic"
        ],
        [
            "name":"Salir",
            "image":"ic_action_close.png",
            "type": "sigout_academic"
        ]
        
        ] as [Any]
    
    static let side_menu_representative = [
        [],
        [
            "name":"Inicio",
            "image":"ic_action_ic_home.png",
            "type": "home_representative"
        ],
        [
            "name":"Ver Perfil universidad",
            "image":"ic_action_ic_school.png",
            "type": "profile_university"
        ],
        [
            "name":"Ver Perfil representante",
            "image":"ic_telefono.png",
            "type": "profile_representative"
        ],
        [
            "name":"Notificaciones",
            "image":"ic_action_notifications.png",
            "type": "notifications"
        ],
        [
            "name":"Cerrar sesión",
            "image":"ic_action_close.png",
            "type": "sigout"
        ]
        
        ] as [Any]
    
}
