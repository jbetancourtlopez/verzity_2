import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import SystemConfiguration
import SwiftyUserDefaults

class PackagesViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var webServiceController = WebServiceController()
    var items:NSMutableArray = []
    var selected_idPaquete = 0;
    var have_package = false
    var usuario = Usuario()
    var idPaquete: Int?
    var package: JSON = JSON()

    // Init Paypal
    var payPalConfig = PayPalConfiguration()
    //PayPalEnvironmentSandbox o PayPalEnvironmentNoNetwork
    //PayPalEnvironmentProduction
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
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        
        print(usuario)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1000.0
        setup_ux()
        load_data()
        setup_paypal()
        setup_back_button()
    
        self.idPaquete = self.usuario.Persona?.Universidades?.VestasPaquetes?.idPaquete
    
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
    
    func setup_back_button(){
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let button_back = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(on_click_back))
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.setTitle("Inicio", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(on_click_back), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = button_back
    }
    
    @objc func on_click_back(sender: AnyObject) {
        print("Atras")
        if !have_package {
            
            let yesAction = UIAlertAction(title: "Aceptar", style: .default) { (action) -> Void in
                
                // Borramos los datos de session
                self.setSettings(key: "profile_menu", value: "")
                self.delete_session()
                _ = self.navigationController?.popToRootViewController(animated: false)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavigationControllerID") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .default) { (action) -> Void in
            }
            
            showAlert("¿Desea cancelar la compra?", message: StringsLabel.cancel_buy, okAction: yesAction, cancelAction: cancelAction, automatic: false)

        }else{
            _ = self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_UniversityViewController") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        
    }
    
    func load_data(){
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetPaquetesDisponibles(parameters: parameter_json_string!, doneFunction: GetPaquetesDisponibles)
    }
    
    func GetPaquetesDisponibles(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            self.items = []
            tableView.reloadData()
            let list_items = json["Data"].arrayValue
            for i in 0..<list_items.count{
                var item = JSON(list_items[i])
                if item["idPaquete"].intValue == self.idPaquete{
                    have_package = true
                    self.items.add(item)
                }
            }
            
            for i in 0..<list_items.count{
                var item = JSON(list_items[i])
                
                if item["idPaquete"].intValue != self.idPaquete{
                    self.items.add(item)
                }
            }
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        self.title = "Paquetes"
        self.navigationItem.leftBarButtonItem?.title = ""
        showGifIndicator(view: self.view)
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.items.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PackageTableViewCell
        
        var item = JSON(items[indexPath.section])
        debugPrint(item)
        
        //Evento al Boton
        cell.button_buy.addTarget(self, action: #selector(self.on_click_buy), for:.touchUpInside)
        cell.button_buy.tag = indexPath.section
        
        // Precio
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        let amount = item["dcCosto"].doubleValue
        let formattedString = formatter.string(for: amount)
        cell.price.text = String(format: "$ %.02f MXN", item["dcCosto"].doubleValue)
        
        cell.title_top.text = item["nbPaquete"].stringValue
        cell.vigency.text = "\(item["dcDiasVigencia"].stringValue) días de vigencia. "
        cell.description_package.text = item["desPaquete"].stringValue
        
        //cell.description_package.translatesAutoresizingMaskIntoConstraints = true
        //cell.description_package.sizeToFit()
        //cell.description_package.isScrollEnabled = false
        
        var height = cell.description_package.frame.height
        cell.content_package.frame.size.height = 560
        
        // Aplica
        if (item["fgProspectus"].boolValue) {
            cell.fgProspectus.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgProspectus.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaImagenes"].boolValue) {
            cell.fgAplicaImagenes.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaImagenes.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaContacto"].boolValue) {
            cell.fgAplicaContacto.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaContacto.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaPostulacion"].boolValue) {
            cell.fgAplicaPostulacion.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaPostulacion.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaLogo"].boolValue) {
            cell.fgAplicaLogo.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaLogo.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaProspectusVideos"].boolValue) {
            cell.fgAplicaProspectusVideos.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaProspectusVideos.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaBecas"].boolValue) {
            cell.fgAplicaBecas.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaBecas.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaUbicacion"].boolValue) {
            cell.fgAplicaUbicacion.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaUbicacion.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaDescripcion"].boolValue) {
            cell.fgAplicaDescripcion.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaDescripcion.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaFavoritos"].boolValue) {
            cell.fgAplicaFavoritos.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaFavoritos.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaDireccion"].boolValue) {
            cell.fgAplicaDireccion.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaDireccion.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaFinanciamiento"].boolValue) {
            cell.fgAplicaFinanciamiento.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaFinanciamiento.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaProspectusVideo"].boolValue) {
            cell.fgAplicaProspectusVideo.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaProspectusVideo.image = UIImage(named: "ic_action_close_check")
        }
        
        if (item["fgAplicaRedes"].boolValue) {
            cell.fgAplicaRedes.image = UIImage(named: "ic_action_ok_check")
        }else{
            cell.fgAplicaRedes.image = UIImage(named: "ic_action_close_check")
        }

        //--
        
        if item["idPaquete"].intValue == self.idPaquete!{
            cell.button_buy.setTitle("PAQUETE ACTUAL", for: .normal)
            cell.button_buy.isEnabled = true
        }else{
            cell.button_buy.setTitle("COMPRAR", for: .normal)
            cell.button_buy.isEnabled = true
        }
        
        // setup_ux
        cell.clipsToBounds = true
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 4
        cell.layer.shadowOffset = CGSize(width:1, height:-20)
        let borderColor: UIColor = Colors.green_dark
        cell.layer.borderColor = borderColor.cgColor
        
        return cell
    }
    
    func setup_paypal(){
        
        let desRutaTerminos = Defaults[.desRutaTerminos]
        
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Verzity"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: desRutaTerminos!)! as URL
        payPalConfig.merchantUserAgreementURL = NSURL(string: desRutaTerminos!)! as URL
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
                // Guardar el Paquete
                self.showGifIndicator(view: self.view)

                let array_parameter = [
                    "idUniversidad": self.usuario.Persona?.Universidades?.idUniversidad,
                    "idPaquete": self.selected_idPaquete,
                    "fgPaqueteActual": false,
                    "fgRecurrente": false,
                    "numReferenciaPayPal": id
                    ] as [String : Any]
                
                let parameter_json = JSON(array_parameter)
                let parameter_json_string = parameter_json.rawString()
                self.webServiceController.SaveVentaPaquete(parameters: parameter_json_string!, doneFunction: self.SaveVentaPaquete)
            }else{
                self.showMessage(title: "El pago fue rechazado", automatic: true)
            }

        })
    }
    
    func SaveVentaPaquete(status: Int, response: AnyObject){
         hiddenGifIndicator(view: self.view)
        let json = JSON(response)
        if status == 1{
            
            print("Guardando Paquete")
            
            var ventasPaquetes_json = JSON(json["Data"])
            var paquete_json = JSON(ventasPaquetes_json["Paquete"])
            
            
            if let usuario_db = realm.objects(Usuario.self).first{
                try! realm.write {
                    let ventasPaquetes = VestasPaquetes()
                    let paquete = Paquete()
                    
                    paquete.idPaquete = paquete_json["idPaquete"].intValue
                    paquete.idEstatus = paquete_json["idEstatus"].intValue
                    paquete.cvPaquete = paquete_json["cvPaquete"].stringValue
                    paquete.nbPaquete = paquete_json["nbPaquete"].stringValue
                    paquete.desPaquete = paquete_json["desPaquete"].stringValue
                    paquete.dcDiasVigencia = paquete_json["dcDiasVigencia"].stringValue
                    paquete.fgAplicaBecas = paquete_json["fgAplicaBecas"].stringValue
                    paquete.fgAplicaFinanciamiento = paquete_json["fgAplicaFinanciamiento"].stringValue
                    paquete.fgAplicaPostulacion = paquete_json["fgAplicaPostulacion"].stringValue
                    paquete.fgAplicaProspectus = paquete_json["fgProspectus"].stringValue
                    paquete.fgAplicaLogo = paquete_json["fgAplicaLogo"].stringValue
                    paquete.fgAplicaDireccion = paquete_json["fgAplicaDireccion"].stringValue
                    paquete.fgAplicaFavoritos = paquete_json["fgAplicaFavoritos"].stringValue
                    paquete.fgAplicaUbicacion = paquete_json["fgAplicaUbicacion"].stringValue
                    paquete.fgAplicaRedes = paquete_json["fgAplicaRedes"].stringValue
                    paquete.fgAplicaProspectusVideo = paquete_json["fgAplicaProspectusVideo"].stringValue
                    paquete.fgAplicaProspectusVideos = paquete_json["fgAplicaProspectusVideos"].stringValue
                    paquete.fgAplicaAplicaImagenes = paquete_json["fgAplicaImagenes"].stringValue
                    paquete.fgAplicaContacto = paquete_json["fgAplicaContacto"].stringValue
                    paquete.fgAplicaDescripcion = paquete_json["fgAplicaDescripcion"].stringValue
                    
                    ventasPaquetes.idVentasPaquetes = ventasPaquetes_json["fgPaqueteActual"].intValue
                    ventasPaquetes.idUniversidad = ventasPaquetes_json["idUniversidad"].intValue
                    ventasPaquetes.idPaquete = ventasPaquetes_json["idPaquete"].intValue
                    ventasPaquetes.feVenta = ventasPaquetes_json["feVenta"].stringValue
                    ventasPaquetes.feVigencia = ventasPaquetes_json["feVigencia"].stringValue
                    ventasPaquetes.fgPaqueteActual = ventasPaquetes_json["fgPaqueteActual"].stringValue
                    ventasPaquetes.fgRecurrente = ventasPaquetes_json["fgRecurrente"].stringValue
                    ventasPaquetes.numReferenciaPaypal = ventasPaquetes_json["numReferenciaPayPal"].stringValue
                    
                    ventasPaquetes.Paquete = paquete
                    usuario_db.Persona?.Universidades?.VestasPaquetes = ventasPaquetes
                }
            }
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "DetailBuyViewControllerID") as! DetailBuyViewController
            customAlert.info = json as AnyObject
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
            
        }else{
            showMessage(title: response as! String, automatic: true)
        }
    }
    
    @objc func on_click_buy(sender: UIButton){
        let index = sender.tag
        var package = JSON(self.items[index])
        if package["idPaquete"].intValue == self.idPaquete!{
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "DetailBuyViewControllerID") as! DetailBuyViewController
            customAlert.info = package as AnyObject
            customAlert.is_summary = 1
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
        }else{
            if (self.idPaquete! > 0){
                let yesAction = UIAlertAction(title: "Aceptar", style: .default) { (action) -> Void in
                    self.payment(index: index)
                }
                
                let cancelAction = UIAlertAction(title: "Cancelar", style: .default) { (action) -> Void in
                }
                
                showAlert("Atención", message: "Ya cuenta con un paquete activo. ¿Desea actualizarlo?", okAction: yesAction, cancelAction: cancelAction, automatic: false)
            }else{
                self.payment(index: index)
            }
        }
    }
    
    func payment(index:Int){
        self.package = JSON(self.items[index])
        
        // Process Payment once the pay button is clicked.
        self.selected_idPaquete = package["idPaquete"].intValue
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
}

extension PackagesViewController: DetailBuyViewControllerDelegate {
    func okButtonTapped(is_summary:Int) {
        
        print(self.have_package)
        
        if self.have_package == false {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileUniversityViewControllerID") as! ProfileUniversityViewController
            self.show(vc, sender: nil)
        }else{
            if  is_summary == 0{
                _ = self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
