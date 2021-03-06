import UIKit

class ListTableViewCell: UITableViewCell{
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
}

class AcademicsTableViewCell: UITableViewCell{
 
    @IBOutlet var name: UILabel!
    @IBOutlet var swich_item: CustomSwich!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NotificationsTableViewCell: UITableViewCell{
    
    @IBOutlet var image_notification: UIImageView!
    @IBOutlet var title_notification: UITextView!
    @IBOutlet var description_notificaction: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class PostuladosTableViewCell: UITableViewCell{
    @IBOutlet var postulate_name_academic: UILabel!
    @IBOutlet var postulate_date: UILabel!
    @IBOutlet var postulate_day: UILabel!
    @IBOutlet var postulate_university: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class AsesorTableViewCell: UITableViewCell{
    @IBOutlet var photo_asesor: UIImageView!
    @IBOutlet var buton_select: UIButton!
    @IBOutlet var description_asesor: UITextView!
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class HeaderTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
}

class PackageTableViewCell: UITableViewCell {

    @IBOutlet var content_package: UIView!
    @IBOutlet var title_top: UILabel!
    
   
    @IBOutlet var price: UILabel!
    @IBOutlet var description_package: UITextView!
    @IBOutlet var button_buy: UIButton!
    @IBOutlet var vigency: UILabel!

    // Label
    @IBOutlet var label_prospectus: UILabel!
    @IBOutlet var label_beca: UILabel!
    @IBOutlet var label_postulacion: UILabel!
     @IBOutlet var label_financing: UILabel!
    
    // Imagenes
    @IBOutlet var fgProspectus: UIImageView!
    @IBOutlet var fgAplicaImagenes: UIImageView!
    @IBOutlet var fgAplicaContacto: UIImageView!
    @IBOutlet var fgAplicaPostulacion: UIImageView!
    @IBOutlet var fgAplicaLogo: UIImageView!
    @IBOutlet var fgAplicaProspectusVideos: UIImageView!
    @IBOutlet var fgAplicaDescripcion: UIImageView!
    @IBOutlet var fgAplicaBecas: UIImageView!
    @IBOutlet var fgAplicaUbicacion: UIImageView!
    @IBOutlet var fgAplicaFavoritos: UIImageView!
    @IBOutlet var fgAplicaDireccion: UIImageView!
    @IBOutlet var fgAplicaFinanciamiento: UIImageView!
    @IBOutlet var fgAplicaProspectusVideo: UIImageView!
    @IBOutlet var fgAplicaRedes: UIImageView!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class VideoTableViewCell: UITableViewCell{

    @IBOutlet var title: UILabel!
    @IBOutlet var video_description: UITextView!
    @IBOutlet var viewYoutube: YTPlayerView!
    
    @IBOutlet var playerView: PlayerViewClass!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class QuestionTableViewCell: UITableViewCell{

    @IBOutlet var photo_question: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var buton_start: CustomButon!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class QuizTableViewCell: UITableViewCell {
    @IBOutlet var answer: UILabel!
    @IBOutlet weak var switch_answer: CustomSwich!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CardTableViewCell: UITableViewCell{
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var btnShowMore: UIButton!
    @IBOutlet weak var imageBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
