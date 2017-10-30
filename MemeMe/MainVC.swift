import UIKit
import Foundation

class MainVC: UIViewController {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var containerView: MemeContainerView!
    @IBOutlet weak var selectPhotoLabel: UILabel!
    
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButtton: UIBarButtonItem!
    @IBOutlet weak var fontButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    

    @IBOutlet weak var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldContraint: NSLayoutConstraint!
    
    var fontTableView: UITableView!
    var fontNames: [String]!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var selectedImage: UIImage?
    var meme: Meme?
    

    // MARK: - Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide done button
        doneButton.isEnabled = false
        doneButton.tintColor = .clear
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        addTapGestureRecognizerToContainerView()
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kImpactFontName, size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20)!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // It took days to find this line of code. Stops messing up the CutsomScrollView centering.
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set up UI for meme if coming from Edit button
        if let realMeme = meme {
            loadMemeForEditing(realMeme)
        }
        else {
            let isImageNil = selectedImage == nil
            selectPhotoLabel.isHidden = !isImageNil
            shareButtton.isEnabled = !isImageNil
            albumButton.isEnabled = isImageNil
            topTextField.isHidden = isImageNil
            bottomTextField.isHidden = isImageNil
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotifications()
        subscribeToOrientationNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
        unsubscribeFromOrientationNotifications()
    }
    

    
    // MARK: - Buttons / Gestures
    
    @IBAction func pickImageTapped(_ sender: UIBarButtonItem) {
        
        presentPickerViewControllerWithSourceType(.photoLibrary)
        
    }

    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
       
        presentPickerViewControllerWithSourceType(.camera)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        func presentErrorAlert() {
            let alertVC = UIAlertController.init(title: "Something went wrong.", message: "Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
        
        if let memeImage = captureMemeImage() {
            let activityVC = UIActivityViewController.init(activityItems: [memeImage], applicationActivities: nil)
            
            activityVC.completionWithItemsHandler = { [unowned self] (activityType, completed, returnedItems, activityError) in
                
                if completed {
                    
                    self.saveMeme(memeImage, originalImage: self.selectedImage, sender: sender)
                    
                }
                else if let returnedItems = returnedItems {
                    // TODO: How to handle the details of these errors?
                    print("returnedItems: \(String(describing: returnedItems))")
                    presentErrorAlert()
                }
                else if let error = activityError {
                    // TODO: How to handle the details of these errors?
                    print("non nil errors: \(String(describing: error))")
                    presentErrorAlert()
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                activityVC.modalPresentationStyle = UIModalPresentationStyle.popover
                present(activityVC, animated: true)
                
                if let popover = activityVC.popoverPresentationController {
                    popover.barButtonItem = shareButtton
                }
            }
            else {
                present(activityVC, animated: true)
            }
        }
        else {
            presentErrorAlert()
        }
    }
    
    
    @IBAction func fontButtonTapped(_ sender: UIBarButtonItem) {
        
        resignWhomeverIsFirstResponder()
        displayFontTableView()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Need to resignFirstResponder begore navigation
        resignWhomeverIsFirstResponder()
        
        if meme == nil {
            // Leave from creating new meme
            
            tabBarController?.animateToTab(toIndex: 0)
            self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[0]
        }
        else {
            // We came from detailVC to edit meme. Leave accordingly
            
            let collectionNav = tabBarController?.viewControllers?[0] as! UINavigationController
            let tableNav = tabBarController?.viewControllers?[1] as! UINavigationController
            
            if collectionNav.viewControllers.count > 1 {
                // select collection view in tab bar controller
                tabBarController?.animateToTab(toIndex: 0)
                tabBarController?.selectedIndex = 0
            }
            else if tableNav.viewControllers.count > 1 {
                // selecct table view in tab bar controller
                tabBarController?.animateToTab(toIndex: 1)
                tabBarController?.selectedIndex = 1
            }
            else {
                print("Cancel button logic does not work correctly. :(")
            }
            
        }
        
        resetEditorUI()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        if let memeImage = captureMemeImage() {
            if let originalImg = meme?.originalImage {
                saveMeme(memeImage, originalImage: originalImg, sender: sender)
            }
        }
    }
    
    
    func addTapGestureRecognizerToContainerView() {
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapRecognized(_:)))
        tapGestureRecognizer = tapRecognizer
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func tapRecognized(_ tapGestureRecognizer: UITapGestureRecognizer) {
        
        if fontTableView != nil {
            dismissFontTableView()
        }
        else {
            resignWhomeverIsFirstResponder()
        }
    }
    
    func displayFontTableView() {
        
        var fontNamesArray = [String]()
        let  fontFamilies = UIFont.familyNames
        fontFamilies.forEach { (family) in
            fontNamesArray += UIFont.fontNames(forFamilyName: family)
        }
        fontNamesArray.insert("Preferred meme font!", at: 0)
        fontNames = fontNamesArray
        
        let x: CGFloat = 0.0
        let y = view.frame.size.height / 2
        let width = view.frame.size.width
        let height = view.frame.size.height / 2
        let tvFrame = CGRect(x: x, y: view.frame.size.height, width: width, height: height)
        
        let fontTV = UITableView.init(frame: tvFrame)
        fontTV.delegate = self
        fontTV.dataSource = self
        fontTV.register(UITableViewCell.self, forCellReuseIdentifier: "fontCell")
        
        fontTableView = fontTV
        view.addSubview(fontTV)
        
        UIView.animate(withDuration: 0.25) { 
            self.fontTableView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    func dismissFontTableView() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.fontTableView.frame = CGRect(x: self.fontTableView.frame.origin.x , y: self.view.frame.size.height, width: self.fontTableView.frame.size.height, height: self.fontTableView.frame.size.width)
        }
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.fontTableView.frame = CGRect(x: self.fontTableView.frame.origin.x , y: self.view.frame.size.height, width: self.fontTableView.frame.size.height, height: self.fontTableView.frame.size.width)
        }) { (bool) in
            self.fontTableView.removeFromSuperview()
            self.fontTableView = nil
        }
    }
    
    // MARK - Rotation methods
    func subscribeToOrientationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeFromOrientationNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func rotated() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            if view.frame.size.height > view.frame.size.width {
                topTextFieldConstraint.constant = 56
                bottomTextFieldContraint.constant = 56
            }
            else {
                topTextFieldConstraint.constant = 28
                bottomTextFieldContraint.constant = 28
            }
        }
        else {
            if view.frame.size.height > view.frame.size.width {
                topTextFieldConstraint.constant = 84
                bottomTextFieldContraint.constant = 84
            }
            else {
                topTextFieldConstraint.constant = 112
                bottomTextFieldContraint.constant = 112
            }
        }
    }
    
    // MARK: - Font Methods
    
    func applyGlobalFont() {
        
        let placeholderAttributesDict = placeholderFontAttributesDict()
        
        // Change font for attributed text already in textViews
        if topTextField.attributedText!.length > 0 && isPlaceholderAttributedString(topTextField.attributedText!) {
            addTopPlaceholderTextWithAttributes(placeholderAttributesDict)
        }
        else {
            topTextField.attributedText = NSAttributedString(string: topTextField.attributedText!.string, attributes:  memeFontAttributesDict())
        }
        
        if bottomTextField.attributedText!.length > 0 && isPlaceholderAttributedString(bottomTextField.attributedText!) {
            addBottomPlaceholderTextWithAttributes(placeholderAttributesDict)
        }
        else {
            bottomTextField.attributedText = NSAttributedString(string: bottomTextField.attributedText!.string, attributes:  memeFontAttributesDict())
        }
        
        selectPhotoLabel.font = kDefaultFont
    }
    
    // MARK: - Meme Image Methods
    
    func saveMeme(_ memedImage: UIImage?, originalImage: UIImage?, sender: UIBarButtonItem) {
        let topText = isPlaceholderAttributedString(topTextField.attributedText!) ? "" : topTextField.attributedText!.string
        let bottomText = isPlaceholderAttributedString(bottomTextField.attributedText!) ? "" : bottomTextField.attributedText!.string

        
        if let realMemeImage = memedImage, let realOriginalImage = originalImage {

            let realFontName = (memeFontAttributesDict()[NSFontAttributeName] as? UIFont)?.fontName ?? kdefaultFontName
            
            let newMeme = Meme.init(topText: topText, bottomText: bottomText, originalImage: realOriginalImage, memedImage: realMemeImage, fontName: realFontName, imageOffset: containerView.customScrollView.contentOffset, zoomScale: containerView.customScrollView.zoomScale)
            
            
            // Add meme to shared data array
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if sender == self.doneButton {
                let memeIndex = appDelegate.memes.index(of: meme!) ?? appDelegate.memes.count
                appDelegate.memes[memeIndex] = newMeme
            }
            else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.memes.append(newMeme)
            }

            
            // TODO: Show success alert for save
            
            
            // Navigation after save
            if self.meme != nil {
                // Needs to dismiss detail VC and navigate back to collection view
                (tabBarController?.viewControllers?[0] as! UINavigationController).popToRootViewController(animated: false)
                (tabBarController?.viewControllers?[1] as! UINavigationController).popToRootViewController(animated: false)
            }

            tabBarController?.animateToTab(toIndex: 0)
            tabBarController?.selectedIndex = 0
            
            resetEditorUI()
        }
        else {

            let alertController = UIAlertController(title: "Error: Save failed", message: "There was a problem saving your meme. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    
    func captureMemeImage() -> UIImage? {
        
        resignWhomeverIsFirstResponder()
        removePlaceholderText()
        toolbar.isHidden = true
        
        var image: UIImage?
        
        if let memeImage = containerView.memeImage() {
            image = memeImage
        }
        else {
            
            let alertController = UIAlertController(title: "Error: capture fail", message: "There was a problem saving your meme. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { [unowned self] (alert) in
                self.dismiss(animated: true)
            })
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
        
        replacePlaceholderText()
        toolbar.isHidden = false
        
        return image
    }
    
    func loadMemeForEditing(_ meme: Meme) {
        
        // Set meme font
        kdefaultFontName = meme.fontName
        applyGlobalFont()
        
        // Adjust UI for loaded meme
        selectPhotoLabel.isHidden = true
        shareButtton.isEnabled = true
        topTextField.isHidden = false
        bottomTextField.isHidden = false
        albumButton.isEnabled = false
        
        doneButton.isEnabled = true
        doneButton.tintColor = navigationController?.navigationBar.tintColor
        
        // Setup scroll view
        containerView.addCustomScrollViewWithImage(meme.originalImage)
        containerView.customScrollView.zoomScale = meme.zoomScale
        containerView.customScrollView.contentOffset = meme.imageOffset
    
        
        //Set textField attributed strings
        let topText = NSMutableAttributedString.init(string: meme.topText!)
        topText.addAttributes(memeFontAttributesDict(), range: NSRange.init(location: 0, length: topText.length))
        topTextField.attributedText = topText
        
        let bottomText = NSMutableAttributedString.init(string: meme.bottomText!)
        bottomText.addAttributes(memeFontAttributesDict(), range: NSRange.init(location: 0, length: bottomText.length))
        bottomTextField.attributedText = bottomText
        
        
        // Become first responder so user knows edit is happening
        topTextField.becomeFirstResponder()
    }
    
    func resetEditorUI() {

        // Text field reset
        topTextField.typingAttributes = [:]
        topTextField.defaultTextAttributes = [:]
        bottomTextField.typingAttributes = [:]
        bottomTextField.defaultTextAttributes = [:]
        resignWhomeverIsFirstResponder()
        
        // container view
        containerView.customScrollView = nil
        
        containerView.removeCustomScrollView()
        
        // properties
        selectedImage = nil
        meme = nil
        
        // update UI
        selectPhotoLabel.isHidden = false
        shareButtton.isEnabled = false
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        
        doneButton.isEnabled = false
        doneButton.tintColor = .clear
        
        // reset font
        kdefaultFontName = kImpactFontName
        selectPhotoLabel.font = kDefaultFont
    }
    
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(_ notification: NSNotification) {

        animateKeyboardWithNotification(notification)
    }
    
    func keyboardWillDisappear(_ notification: NSNotification) {
        
        if view.frame.origin.y < 0 {
            animateKeyboardWithNotification(notification)
        }
    }
    
    func animateKeyboardWithNotification(_ notification: NSNotification) {
        let newY: CGFloat!
        let newFrame: CGRect!
        
        if notification.name == NSNotification.Name.UIKeyboardWillShow && view.frame.origin.y == 0 && bottomTextField.isFirstResponder {
            newY = view.frame.origin.y - self.getKeyboardHeight(notification: notification)
            newFrame = CGRect(x: 0.0, y: newY , width: view.frame.size.width, height: view.frame.size.height)
        }
        else {
            newY = 0.0
            newFrame = CGRect(x: 0.0, y: newY , width: view.frame.size.width, height: view.frame.size.height)
        }
    
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = UIViewAnimationCurve(rawValue: Int(notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber))
            
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(animationCurve!)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.frame = newFrame
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat  {
        
        let userInfo = notification.userInfo
        if let keyboardHeight = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            return keyboardHeight.cgRectValue.height - toolbar.frame.size.height
        }
        
        return 0.0
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }
    
    
}


// MARK: - Image Picker Delegate

extension MainVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        containerView.removeCustomScrollView()
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            
            selectedImage = (editedImage as! UIImage)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] {
            
            selectedImage = (image as! UIImage)
        }
        
        
        if let realImage = selectedImage {
            
            containerView.addCustomScrollViewWithImage(realImage)
            
            addPlaceholderAttributedTextToTextViews()
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func presentPickerViewControllerWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.sourceType = sourceType
        
        navigationController?.present(pickerVC, animated: true)
        
        pickerVC.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Impact", size: 17) as Any]
    }
    
    
}


// MARK: - Navigation Controller Delegate

extension MainVC: UINavigationControllerDelegate {
    
}

// MARK: - TextField Delegate

extension MainVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if fontTableView != nil {
            dismissFontTableView()
        }
        
        let memeFontAttributes = memeFontAttributesDict()
        textField.typingAttributes = memeFontAttributes
        textField.defaultTextAttributes = memeFontAttributes
        
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == Placeholder.topText || textField.text == Placeholder.bottomText {
            textField.text = ""
        }
        
        let memeFontAttributes = memeFontAttributesDict()
        textField.typingAttributes = memeFontAttributes
        textField.defaultTextAttributes = memeFontAttributes
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        textField.typingAttributes = [:]
        textField.defaultTextAttributes = [:]
        
        if textField.text?.characters.count == 0 {
        
            if textField == topTextField {
                addTopPlaceholderTextWithAttributes(placeholderFontAttributesDict())
            }
            else if textField == bottomTextField {
                addBottomPlaceholderTextWithAttributes(placeholderFontAttributesDict())
            }
        }
        else {
            textField.defaultTextAttributes = memeFontAttributesDict()
        }
    }

    
    // MARK: Non Delegate TextView Methods
    
    func resignWhomeverIsFirstResponder() {
        
        if topTextField.isFirstResponder {
            topTextField.resignFirstResponder()
        }
        else {
            bottomTextField.resignFirstResponder()
        }
    }
    
    func memeFontAttributesDict() -> [String: Any] {
        
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let textAttributesDict: [String : Any] = [NSStrokeColorAttributeName: UIColor.black,
                                                  NSFontAttributeName: kDefaultFont ?? UIFont(name: kdefaultFontName, size: fontSize)!,
                                                  NSStrokeWidthAttributeName:  -5.0,
                                                  NSForegroundColorAttributeName: UIColor.white,
                                                  NSParagraphStyleAttributeName: paragraphStyle]
        
        return textAttributesDict
    }
    
    func placeholderFontAttributesDict() -> [String: Any] {
        
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 80.0 : 40.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let placeholderAttributesDict: [String : Any] = [NSForegroundColorAttributeName: UIColor.red.withAlphaComponent(0.50),
                                                         NSFontAttributeName: kDefaultFont ?? UIFont.systemFont(ofSize: fontSize),
                                                         NSParagraphStyleAttributeName: paragraphStyle]
        
        return placeholderAttributesDict
    }
    
    func addPlaceholderAttributedTextToTextViews() {
        
        let placeholderAttributes = placeholderFontAttributesDict()
        
        addTopPlaceholderTextWithAttributes(placeholderAttributes)
        addBottomPlaceholderTextWithAttributes(placeholderAttributes)
    }
    
    func addTopPlaceholderTextWithAttributes(_ attributes: [String: Any]) {
        
        let topAttributedText = NSMutableAttributedString.init(string: Placeholder.topText)
        topAttributedText.addAttributes(attributes, range: NSRange.init(location: 0, length: topAttributedText.length))
        
        topTextField.attributedText = topAttributedText
    }
    
    func addBottomPlaceholderTextWithAttributes(_ attributes: [String: Any]) {
        
        let bottomAttributedText = NSMutableAttributedString.init(string: Placeholder.bottomText)
        bottomAttributedText.addAttributes(attributes, range: NSRange.init(location: 0, length: bottomAttributedText.length))
        
        bottomTextField.attributedText = bottomAttributedText
    }
    
    
    func removePlaceholderText() {
        
        if topTextField.attributedText!.length > 0 && isPlaceholderAttributedString(topTextField.attributedText!) {
            topTextField.attributedText = NSAttributedString.init(string: "")
        }
        
        if bottomTextField.attributedText!.length > 0 && isPlaceholderAttributedString(bottomTextField.attributedText!) {
            bottomTextField.attributedText = NSAttributedString.init(string: "")
        }
    }
    
    func replacePlaceholderText() {
        
        let placeholderAttributes = placeholderFontAttributesDict()
        
        if topTextField.attributedText?.string == "" {
            addTopPlaceholderTextWithAttributes(placeholderAttributes)
        }
        if bottomTextField.attributedText?.string == "" {
            addBottomPlaceholderTextWithAttributes(placeholderAttributes)
        }
        
    }
    
    func isPlaceholderAttributedString(_ attributedString: NSAttributedString) -> Bool {
        
        return attributedString.attributes(at: 0, effectiveRange: nil)[NSForegroundColorAttributeName] as! UIColor == UIColor.white ? false : true
    }

}

// MARK: - Font Table View methods
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontCell", for: indexPath)
        
        let pointSize = cell.textLabel?.font.pointSize ?? 17.0

        cell.textLabel?.font = indexPath.row == 0 ? kPreferredFont : UIFont(name: fontNames[indexPath.row], size: pointSize)
        
        cell.textLabel?.text = fontNames[indexPath.row]
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        kdefaultFontName = indexPath.row == 0 ? kPreferredFont!.fontName : fontNames[indexPath.row]
        
        dismissFontTableView()
        
        applyGlobalFont()
    }
    
}
