import UIKit
import FloatableTextField
import SwiftyJSON

class QuestionResultViewController: BaseViewController, UIWebViewDelegate {

    // Inputs
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var title_question: UILabel!
    @IBOutlet weak var view_result: UIView!
    @IBOutlet weak var puntaje: UILabel!
    @IBOutlet weak var web_view: UIWebView!

    
    // Variables
    var webServiceController = WebServiceController()
    var delegate: QuestionResultViewControllerDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    var question:JSON = JSON()
    var webView = UIWebView()
    var usuario = Usuario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.question)
        self.usuario = get_user()
        load_data()
        self.web_view.delegate = self
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        web_view.frame.size.height = 1
        web_view.frame.size = webView.sizeThatFits(CGSize.zero)
        var height = self.web_view.frame.height
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
        
        var evaluacion = JSON(self.question["Evaluaciones"])
        
        let array_parameter = [
            "idPersona": usuario.Persona?.idPersona,
            "idEvaluacion":evaluacion["idEvaluacion"].intValue
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "getResultado", doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        //print(json)
        if status == 1{
            var data = JSON(json["Data"])
            title_question.text = data["nombreEvaluacion"].stringValue
            puntaje.text = data["puntaje"].stringValue
            let html = data["mensaje"].stringValue
            let html1 = html.replacingOccurrences(of:"\r", with: "")
            let html2 = html1.replacingOccurrences(of:"\n", with: "")
            let html_v2 = "<div style=\"text-align:center !important; margin: 0 auto !important;\">\(html2)</div>"
            self.web_view.loadHTMLString(html_v2, baseURL: nil)
        }
        hiddenGifIndicator(view: self.view)
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
    }

    @IBAction func on_click_close(_ sender: Any) {
        delegate?.closeButtonTapped()
        
        _ = self.navigationController?.popViewController(animated: false)  //popToRootViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
        //
    }
}

protocol QuestionResultViewControllerDelegate: class {
    func closeButtonTapped()
}
