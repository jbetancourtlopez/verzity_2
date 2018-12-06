import UIKit
import SwiftyJSON
import Kingfisher

class QuizViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
   
    //Inputs
    @IBOutlet weak var view_web: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view_end: UIView!
    @IBOutlet weak var view_ask: UIView!
    @IBOutlet weak var progress_view: UIProgressView!
    
    @IBOutlet weak var label_count: UILabel!
    
    // Varibales
    var items:NSArray = []
    var list_answer:NSArray = []
    var webServiceController = WebServiceController()
    var usuario = Usuario()
    var selected_question = 0
    var selected_switch = -1
    var webView = UIWebView()
    var question: JSON = JSON()
    
    var idEvaluacion = 0
    var idEvaluacionPersona = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        self.usuario = get_user()
        set_webview()
        load_data()
        
        // Eventos
        let event_on_click_finish:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_finish))
        view_end.addGestureRecognizer(event_on_click_finish)
        
        let event_on_click_ask:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_ask))
        view_ask.addGestureRecognizer(event_on_click_ask)
    }
 
    
    func set_webview(){
        self.webView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view_web.frame.size.width, height: self.view_web.frame.size.height))
        self.webView.frame.size.height = 1
        self.webView.frame.size = webView.sizeThatFits(CGSize.zero)
        self.view_web.addSubview(webView)
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
        let idPersona = self.usuario.Persona?.idPersona
        
        if self.idEvaluacion == 0{
           self.idEvaluacion = self.question["idEvaluacion"].intValue
        }
        
        
        let array_parameter = ["idEvaluacion": self.idEvaluacion, "idPersona": idPersona] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "getDetalleEvaluacion", doneFunction: callback_load_data)
        
    } 
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        print(status)
        self.items = []
        if status == 1{
            var data = JSON(json["Data"])
            self.items = data["listPreguntas"].arrayValue as NSArray
            self.idEvaluacion = data["idEvaluacion"].intValue
            self.idEvaluacionPersona = data["idEvaluacionPersona"].intValue
            progress_view.setProgress(0.0, animated: true)
            
            for i in 0 ..< items.count{
                var question = JSON(self.items[i])
                if question["isResuelto"].boolValue {
                    self.selected_question = self.selected_question + 1
                }
            }
          
            set_data_question()

        }else{
            print("Cuestionario")
            _ = self.navigationController?.popViewController(animated: false)

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewControllerID") as! QuestionViewController
            self.show(vc, sender: nil)
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        self.title = self.question["nbEvaluacion"].stringValue
        self.progress_view.transform = self.progress_view.transform.scaledBy(x: 1, y: 10)
    }
    
    // Eventos
    @objc func on_click_finish(){
        print("Terminar")
        
        let yesAction = UIAlertAction(title: "Aceptar", style: .default) { (action) -> Void in
            
            print("SI")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewControllerID") as! QuestionViewController
            self.show(vc, sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default) { (action) -> Void in
            print("No")
        }
        
        showAlert("Atención", message: "¿Desea cancelar la presentación del cuestionario? Se guardará su progreso actual", okAction: yesAction, cancelAction: cancelAction, automatic: false)
    }
    
    @objc func on_click_ask(){
        if selected_switch < 0{
            updateAlert(title: "", message: "Seleccione una respuesta para continuar", automatic: true)
             return
        }
        
        var question = JSON(self.items[self.selected_question])
        var preguntas = (question["Preguntas"])
        var idPregunta = preguntas["idPregunta"].intValue
        var answer = JSON(self.list_answer[self.selected_switch])
        
        let array_parameter = [
            "idEvaluacion": self.idEvaluacion,
            "idEvaluacionPersona": self.idEvaluacionPersona,
            "idPersona": self.usuario.Persona?.idPersona,
            "idPregunta": idPregunta,
            "idRespuesta": answer["idRespuesta"].intValue
        ] as [String : Any]
        
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "guardarRespuesta", doneFunction: call_on_click_ask)
    }
    
    
    func call_on_click_ask(status: Int, response: AnyObject){
        let json = JSON(response)
        print(status)
        if status == 1{
            self.selected_switch = -1;
            showGifIndicator_ext(view: self.view)
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(close_success), userInfo: nil, repeats: false)
            
            self.selected_question = self.selected_question + 1
            if self.selected_question == self.items.count{
                print("Modal de Resultados")
                let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "QuestionResultViewControllerID") as! QuestionResultViewController
                customAlert.providesPresentationContextTransitionStyle = true
                customAlert.definesPresentationContext = true
                customAlert.delegate = self
                customAlert.question = self.question
                self.present(customAlert, animated: true, completion: nil)
            }else{
                print("Cambio de Pregunta")
                set_data_question()
            }
        }
    }
    
    @objc func close_success(){
        hiddenGifIndicator(view: self.view)
    }
    
    // Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.list_answer.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuizTableViewCell
        
        let item_question = JSON(self.list_answer[indexPath.row])
        cell.answer.text = item_question["nbRespuesta"].stringValue
        
        cell.switch_answer.row = indexPath.row
        
        cell.switch_answer.setOn(false, animated: true)
        if self.selected_switch == indexPath.row {
           cell.switch_answer.setOn(true, animated: true)
        }
        
        cell.switch_answer.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

        return cell
    }
    
    @objc func switchChanged(_ sender : CustomSwich!){
        set_active_swich(row: sender.row, section: sender.section, sender : sender!)
    }
    
    func set_active_swich(row:Int, section:Int, sender : CustomSwich!){
        print(row)
        self.selected_switch = row
        tableView.reloadData()
    }
    
    func set_data_question(){
        print(self.selected_question)
        
        print("self.selected_question: \(self.selected_question)")
        
        var progress:Float = Float(self.selected_question) / Float(self.items.count)
        progress_view.progress = progress
        label_count.text = "\(self.selected_question + 1)/\(self.items.count)"
        
        
        var question = JSON(self.items[self.selected_question])
        self.list_answer = question["RespuestasList"].arrayValue as NSArray
        var ask = JSON(question["Preguntas"])
        var html = ask["nbPregunta"].stringValue
        webView.loadHTMLString(html, baseURL: nil)
        tableView.reloadData()
        
    }

}

extension QuizViewController: QuestionResultViewControllerDelegate{
    func closeButtonTapped() {
        print("Close Button")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewControllerID") as! QuestionViewController
        self.show(vc, sender: nil)
    }
}