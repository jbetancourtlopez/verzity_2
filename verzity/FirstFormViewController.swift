import UIKit
import FloatableTextField
import SwiftyJSON
import SwiftyUserDefaults

class FirstFormViewController: BaseViewController, FloatableTextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var first_name_university: FloatableTextField!
    @IBOutlet var first_description: FloatableTextField!
    @IBOutlet var first_web: FloatableTextField!
    @IBOutlet var first_phone: FloatableTextField!
    @IBOutlet var first_email: FloatableTextField!
    
    var usuario = Usuario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        setup_textfield()
        set_data()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications(scrollView: scrollView)
        setGestureRecognizerHiddenKeyboard()
    }
    
    func validate_form()-> Int{
        var count_error:Int = 0
        
        //Nombre universida
        if FormValidate.isEmptyTextField(textField: first_name_university){
            first_name_university.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            first_name_university.setState(.DEFAULT, with: "")
        }
        
        //Descripcion
        if FormValidate.isEmptyTextField(textField: first_description){
            first_description.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            first_description.setState(.DEFAULT, with: "")
        }
        
        //Sitio web
        if FormValidate.isEmptyTextField(textField: first_web){
            first_web.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            if !FormValidate.validateUrl(urlString: first_web.text! as NSString){
                first_web.setState(.FAILED, with: StringsLabel.no_website)
                count_error = count_error + 1
            }else{
                first_web.setState(.DEFAULT, with: "")
            }
        }
        
        //Telefono
        if FormValidate.isEmptyTextField(textField: first_phone){
            first_phone.setState(.FAILED, with: StringsLabel.phone_invalid)
            count_error = count_error + 1
        }else{
            if FormValidate.validatePhone(textField: first_phone){
                first_phone.setState(.FAILED, with: StringsLabel.phone_invalid)
                count_error = count_error + 1
            }else{
            first_phone.setState(.DEFAULT, with: "")
            }
        }
        
        // Email
        if FormValidate.isEmptyTextField(textField: first_email){
            first_email.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            if FormValidate.validateEmail(first_email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                first_email.setState(.FAILED, with: StringsLabel.email_invalid)
                count_error = count_error + 1
            }else{
                first_email.setState(.DEFAULT, with: "")
            }
        }
        return count_error
    }
    
    func setup_textfield(){
        first_name_university.floatableDelegate = self
        first_description.floatableDelegate = self
        first_web.floatableDelegate = self
        first_phone.floatableDelegate = self
        first_email.floatableDelegate = self
    }
    
    func set_data(){
        var univ = Universidades()
        univ = (self.usuario.Persona?.Universidades)!
        first_name_university.text = univ.nbUniversidad
        first_description.text = univ.desUniversidad
        first_web.text = univ.desSitioWeb
        first_phone.text = univ.desTelefono
        first_email.text = univ.desCorreo
    }
    
    @objc(textField:shouldChangeCharactersIn:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
            return true
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        switch textField {
            case first_phone:
                return newString.length <= 10
            default:
                return true
        }
    }
}
