import UIKit

class NeedPermissionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var closeimg: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var subTitleLable: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noticationTableView: UITableView!
    
    var successHandler: ((Bool, String?) -> Void)?
    var failureHandler: ((Bool, String?) -> Void)?
    
    let count = NeedPermissionViewController.notificationList.count
    
    static var titleValue = ""
    static var subTitleValue = ""
    static var descriptionValue = ""
    static var locationStatus = false
    static var notificationStatus = false
    static var cameraStatus = false
    static var blutoothStatus = false
    static var notificationList = [PermissionItem]()
    private let rowHeight: CGFloat = 50.0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        overrideUserInterfaceStyle = .light
        noticationTableView.dataSource = self
        noticationTableView.delegate = self
        noticationTableView.register(UINib(nibName: "Notification",bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "NotificationCell")
        tableViewHeight.constant = CGFloat(Double(count)*111)

    }
    func setupUI() {
        NeedPermissionViewController.titleValue = NeedPermissionViewController.titleValue.isEmpty ? "Need Permissions" : NeedPermissionViewController.titleValue
        NeedPermissionViewController.subTitleValue = NeedPermissionViewController.subTitleValue.isEmpty ? "In order for you use certain features of this app,you need to give permissions.See description for each permission." : NeedPermissionViewController.subTitleValue
        NeedPermissionViewController.descriptionValue = NeedPermissionViewController.descriptionValue.isEmpty ? "Permission are necessary for all the features and functions to work properly. If not allowed,you have to enable permissions in settings." : NeedPermissionViewController.descriptionValue
        closeimg.tintColor = UIColor.darkGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        closeimg.addGestureRecognizer(tapGesture)
        
        titleLable.text = NeedPermissionViewController.titleValue
        subTitleLable.text = NeedPermissionViewController.subTitleValue
        descriptionLable.text = NeedPermissionViewController.descriptionValue
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NeedPermissionViewController.notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let data = NeedPermissionViewController.notificationList[indexPath.row]
        cell.title.text = data.title
        
 // Highlighed one Text
        let description = data.description
        let highlightColor = UIColor.red
        let highlightedText = NSMutableAttributedString(string: description)
        if let range = description.range(of: data.keywordHighlight) {
            let nsRange = NSRange(range, in: description)
            highlightedText.addAttribute(.foregroundColor, value: highlightColor , range: nsRange)
        }
        cell.subTitle.attributedText = highlightedText
    
// Permisson Bool Check
        if data.permissionType == .location{
            if NeedPermissionViewController.locationStatus == false{
                cell.allowBtn.isHidden = false
            }
            else {
                cell.allowBtn.isHidden = true
            }
        }
        else if data.permissionType == .bluetooth{
            if NeedPermissionViewController.blutoothStatus == false {
                cell.allowBtn.isHidden = false
            }
            else {
                cell.allowBtn.isHidden = true
            }
        }
        else if data.permissionType == .camera{
            if NeedPermissionViewController.cameraStatus == false{
                cell.allowBtn.isHidden = false
            }
            else {
                cell.allowBtn.isHidden = true
            }
        }
        else if data.permissionType == .notification{
            if NeedPermissionViewController.notificationStatus == false{
                cell.allowBtn.isHidden = false
            }
            else {
                cell.allowBtn.isHidden = true
            }
        }
        
        if data.permissionType != .bluetooth{
            cell.mainImage.image = UIImage(systemName: data.permissionType.title)
        }
// Open Setting Function
        cell.TicketAction = {
            self.openAppSettings()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    @IBAction func locationAllow(_ sender: Any) {
        openAppSettings()
    }
    
    @IBAction func notiAction(_ sender: Any) {
        openAppSettings()
    }
    
    @IBAction func camAction(_ sender: Any) {
        openAppSettings()
    }
    
    @IBAction func bluAction(_ sender: Any) {
        openAppSettings()
    }
}
extension NeedPermissionViewController {
    @objc func imageTapped() {
        self.dismiss(animated: true)
    }
}

