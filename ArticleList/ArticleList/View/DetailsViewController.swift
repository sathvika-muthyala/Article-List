import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var updateText: UITextField!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var body: UILabel!

    var viewModel: DetailsViewModel!
    var closure: ((Article?) -> Void?)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        updateText.text = viewModel.authorText
        articleTitle.text = viewModel.titleText
        body.text = viewModel.bodyText
        body.numberOfLines = 0

        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(cancelTapped)
            )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(backToPreviousScreen)
        )
        
        viewModel.loadImage { [weak self] image in
            DispatchQueue.main.async {
                self?.articleImg.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
    
    @objc func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func backToPreviousScreen() {
        viewModel.setAuthor(updateText.text)
        closure?(viewModel.article) 
        navigationController?.popViewController(animated: true)
    }
}
