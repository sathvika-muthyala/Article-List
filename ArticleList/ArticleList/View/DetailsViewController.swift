import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var updateText: UITextField!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var body: UILabel!

    var article: Article?
    var closure: ((Article?) -> Void?)? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        updateText.text = article?.author ?? ""
        articleTitle.text = article?.title
        body.text = article?.description
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(backToPreviousScreen)
        )
        loadArticleImage(from: article?.imageUrl)
    }

    @objc func backToPreviousScreen() {
        article?.author = updateText.text ?? ""
        closure?(article)
        navigationController?.popViewController(animated: true)
    }
    private func loadArticleImage(from path: String?) {
        guard let path = path, !path.isEmpty else {
            articleImg.image = UIImage(systemName: "photo")
            return
        }

        guard let url = URL(string: path) else {
            articleImg.image = UIImage(systemName: "photo")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.articleImg.image = img }
        }.resume()
    }
}
