import UIKit
import SwiftyJSON
import Kingfisher

class ListAsesorEmptyViewController: BaseViewController {

    var actionButton : ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
    }
    
    func setup_ux(){
        self.title = "Mi Asesor"
        
        let postularse = ActionButtonItem(title: "Consultar paquetes", image: #imageLiteral(resourceName: "ic_notification_green"))
        postularse.action = { item in self.self.on_click_asesor() }
        
        
        actionButton = ActionButton(attachedToView: self.view, items: [postularse])
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 57.0/255.0, green: 142.0/255.0, blue: 49.0/255.0, alpha: 1)
        actionButton.action = { button in button.toggleMenu()}
    }
    
    func on_click_asesor(){
        print("Paquetes Asesor")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorPaqueteViewControllerID") as! ListAsesorPaqueteViewController
        self.show(vc, sender: nil)
    }

}
