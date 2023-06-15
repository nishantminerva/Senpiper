//
//  ViewController.swift
//  Senpiper
//
//  Created by Nishant Minerva on 15/06/23.
// 0acc78588b134ccd9ead90183d032bdc

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let apiUrl = "https://newsapi.org/v2/top-headlines?country=us&apiKey=0acc78588b134ccd9ead90183d032bdc"
    private var articles: [Article] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Senpiper News"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16), // Add padding of 16 points
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        fetchData()
    }

    
    private func fetchData() {
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let articles = json?["articles"] as? [[String: Any]] {
                    for article in articles {
                        if let title = article["title"] as? String,
                           let author = article["author"] as? String,
                           let description = article["description"] as? String,
                           let imageURLString = article["urlToImage"] as? String,
                           let imageURL = URL(string: imageURLString) {
                            let article = Article(title: title, author: author, description: description, imageURL: imageURL)
                            self?.articles.append(article)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.authorLabel.text = article.author
        cell.descriptionLabel.text = article.description
        cell.articleImageView.image = nil
        
        if let imageURL = article.imageURL {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    let resizedImage = self.resizeImage(image: UIImage(data: imageData), targetSize: CGSize(width: 80, height: 80))
                    DispatchQueue.main.async {
                        if let cellToUpdate = tableView.cellForRow(at: indexPath) as? ArticleTableViewCell {
                            cellToUpdate.articleImageView.image = resizedImage
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    private func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        return resizedImage
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}



