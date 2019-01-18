import UIKit
import FloatableTextField
import SwiftyJSON

class ModalNotificationViewController: BaseViewController {
    
    @IBOutlet weak var alertView: UIView!
    
    var webServiceController = WebServiceController()
    var delegate: ModalNotificationViewControllerDelegate?
    
    
    @IBOutlet weak var label_title: UILabel!
    
    @IBOutlet weak var label_description: UILabel!
    
    var idNotificacion: Int = 0
    var idPersonaRecibe: Int = 0
    var idDiscriminador: Int = 0
    var cvDiscriminador: String = ""
    var desMensaje: String = ""
    var desAsunto: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        set_data()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    func set_data(){
        label_title.text = desAsunto
        label_description.text = desMensaje
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 2
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
//        self.alertView.layer.borderWidth = 1

    }
    
    @IBAction func on_click_answers(_ sender: Any) {
       
        
         print("Answer")
       
        
        delegate?.on_click_answers(idDiscriminador: idDiscriminador, idEvaluacionPersona: idPersonaRecibe)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func on_click_list(_ sender: Any) {
       
        delegate?.on_click_list()
        self.dismiss(animated: true, completion: nil)
    }
    
}


protocol ModalNotificationViewControllerDelegate: class {
    func on_click_answers(idDiscriminador: Int, idEvaluacionPersona: Int)
    func on_click_list()
}
