
import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class ListAsesorSelectedViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate  {
    
    // Inputs
    @IBOutlet var tableView: UITableView!
    
    // Variables
    var webServiceController = WebServiceController()
    var list_items:NSArray = []
    var refreshControl = UIRefreshControl()
    var package: AnyObject  = {} as AnyObject
    
    var selected_idPaquete = 0;
    var asesor: JSON = JSON()
    var have_package = false
    
    var usuario = Usuario()
    var idPaqueteAsesor: Int?
    
    // Init Paypal
    var payPalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
        
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    //End Paypal

    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        load_data()
        setup_paypal()
        
        self.usuario = get_user()
        self.idPaqueteAsesor = self.usuario.Persona?.VestasPaquetesAsesores?.idPaqueteAsesor
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(handleRefresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        self.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        load_data()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    func setup_ux(){
        self.title = "Seleccionar asesor"
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method:"GetAsesores", doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        // Basarse de Paquete
        var json = JSON(response)
        print(json)
        if status == 1{
            list_items = json["Data"].arrayValue as NSArray
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.list_items.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return self.list_items.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
     //Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_asesor", for: indexPath) as! AsesorTableViewCell
        var item = JSON(list_items[indexPath.section])

        //Evento al Boton
        cell.buton_select.addTarget(self, action: #selector(self.on_click_select), for:.touchUpInside)
        cell.buton_select.tag = indexPath.section

        set_photo_profile(url: item["pathFoto"].stringValue, image: cell.photo_asesor)
        cell.photo_asesor.layer.masksToBounds = true
        cell.photo_asesor.layer.cornerRadius = 25
        
        cell.description_asesor.text = item["desPersona"].stringValue
        cell.title.text = item["nbCompleto"].stringValue
        return cell
    }
    
    @objc func on_click_select(sender: UIButton){
        let index = sender.tag
        self.payment(index: index)
    }
    
    func payment(index:Int){
        self.asesor = JSON(list_items[index])
        var package = JSON(self.package)
        
        // Process Payment once the pay button is clicked.
        self.selected_idPaquete = package["idPaqueteAsesor"].intValue
        let currency_code = "MXN"
        let quantity = 1
        let product_name = package["nbPaquete"].stringValue
        let product_price = package["dcCosto"].stringValue
        let product_description_short = package["desPaquete"].stringValue
        let product_sku = "\(product_name)-\(package["cvPaquete"].stringValue)"
        
        // --------
        var item = PayPalItem(name: product_name, withQuantity: UInt(quantity), withPrice: NSDecimalNumber(string: product_price), withCurrency: currency_code, withSku: product_sku)
        
        let items = [item]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: currency_code, shortDescription: product_description_short, intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    func setup_paypal(){
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Verzity"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.google.com")! as URL
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.google.com")! as URL
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController!, didComplete completedPayment: PayPalPayment!) {
        print("PayPal Payment Success !")
        paymentViewController?.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            let confirmation = completedPayment.confirmation
            let response = confirmation["response"] as AnyObject
            let state = response["state"]  as! String
            let id = response["id"]  as! String
            if state == "approved"{
                
                self.showGifIndicator(view: self.view)
                var paq = JSON(self.package)
                
                let array_parameter = [
                    "idVentaPaqueteAsesor": 0,
                    "idPersonaAsesor": self.asesor["idPersona"].intValue,
                    "idPaqueteAsesor": paq["idPaqueteAsesor"].intValue,
                    "idPersona": self.usuario.Persona?.idPersona,
                    "numReferenciaPayPal": id
                ] as [String : Any]


                let parameter_json = JSON(array_parameter)
                let parameter_json_string = parameter_json.rawString()
                self.webServiceController.get(parameters: parameter_json_string!, method:"SaveVentaPaqueteAsesor", doneFunction: self.SaveVentaPaquete)
            
            }else{
                self.showMessage(title: "El pago fue rechazado", automatic: true)
            }
        })
    }
    
    func SaveVentaPaquete(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        let json = JSON(response)
        if status == 1{
            var data = JSON(json["Data"])
            print("Guardando Paquete")
            
            if let usuario_db = realm.objects(Usuario.self).first{
                try! realm.write {
                    let vestasPaquetesAsesores = VestasPaquetesAsesores()
                    vestasPaquetesAsesores.idVentaPaqueteAsesor = data["idVentaPaqueteAsesor"].intValue
                    vestasPaquetesAsesores.idPaqueteAsesor = data["idPaqueteAsesor"].intValue
                    vestasPaquetesAsesores.idPersona = data["idPersona"].intValue
                    vestasPaquetesAsesores.idPersonaAsesor = data["idPersonaAsesor"].intValue
                    vestasPaquetesAsesores.feVenta = data["feVenta"].stringValue
                    vestasPaquetesAsesores.feVigencia = data["feVigencia"].stringValue
                    vestasPaquetesAsesores.fgPaqueteActual = data["fgPaqueteActual"].stringValue
                    vestasPaquetesAsesores.numReferenciaPaypal = data["numReferenciaPayPal"].stringValue
                    vestasPaquetesAsesores.numLiberados = data["numLiberados"].stringValue
                    
                    usuario_db.Persona?.VestasPaquetesAsesores = vestasPaquetesAsesores
                }
            }
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "DetailBuyViewControllerID") as! DetailBuyViewController
            customAlert.info = json as AnyObject
            customAlert.is_paquete_asesor = 1
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
            
        }else{
            showMessage(title: response as! String, automatic: true)
        }
    }
}

extension ListAsesorSelectedViewController: DetailBuyViewControllerDelegate {
    func okButtonTapped(is_summary:Int) {
        if  is_summary == 0{
            _ = self.navigationController?.popViewController(animated: false)
        }
    }
}

