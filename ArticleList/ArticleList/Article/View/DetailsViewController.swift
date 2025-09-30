import UIKit

protocol ArticleDetailsDelegate: AnyObject {
    func didUpdateArticle(_ article: Article, at index: Int)
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var updateText: UITextField!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var body: UILabel!

    var viewModel: DetailsViewModel!
//    var closure: ((Article?) -> Void)?
    var rowIndex: Int?
    
    weak var delegate: ArticleDetailsDelegate?
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
        
        Task { [weak self] in
            guard let self = self else { return }
            let image = await viewModel.loadImage()
            self.articleImg.image = image ?? UIImage(systemName: "photo")
        }

    }
    
    @objc func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func backToPreviousScreen() {
        viewModel.setAuthor(updateText.text)
        if let row = rowIndex {
            delegate?.didUpdateArticle(viewModel.article, at: row)  
        }
        navigationController?.popViewController(animated: true)
    }
}
