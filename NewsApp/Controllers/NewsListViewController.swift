//
//  ViewController.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import UIKit

protocol NewsCellProtocol {
    func configure(with article: Article)
    func loadImage(from url: String?, viewModel: NewsViewModel, completion: @escaping (UIImage?) -> Void)
}

class NewsListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    
    private let vm = NewsViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    var newsData : NewsData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        fetchAndReload()
        configureNavBar()
        pullToRefresh()
    }
    
    // func to reload the data by pulling the tableview from top
    private func pullToRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callFetchFunction(_:)), for: .valueChanged)
    }
    
    @objc func callFetchFunction(_ refreshControl: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fetchAndReload()
            refreshControl.endRefreshing()
        }
    }
    
    // Configure the Navigation bar
    private func configureNavBar() {
        
        navigationItem.title = Constants.NavBarTitle            //  Add Navigation title
        
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    // Fetch the data from the API and reload the TableView
    private func fetchAndReload(){
        self.vm.fetchNewsData()
        self.vm.onFetchData = { [weak self] result in
            DispatchQueue.main.async {
                self?.newsData = result
                self?.tableView.reloadData()
            }
        }
    }
    
    // Register the tableView as well as table view cells
    private func registerTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: ReuseIdentifier.newsListTableViewCell, bundle: nil), forCellReuseIdentifier: ReuseIdentifier.newsListTableViewCell)
        self.tableView.register(UINib(nibName: ReuseIdentifier.newsListTopTableViewCell, bundle: nil), forCellReuseIdentifier: ReuseIdentifier.newsListTopTableViewCell)
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData?.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let article = newsData?.articles?[indexPath.row] else {
            return UITableViewCell()
        }
        
        // Used different table view cell to look the UI better
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsListTopTableViewCell, for: indexPath) as! NewsListTopTableViewCell
            cell.configure(with: article)
            
            cell.loadImage(from: article.urlToImage, viewModel: vm) { image in
                
            // In case of null value for image
                guard let image = image else {
                    cell.newsImage.image = UIImage(named: "newsImage")
                    return
                }
                cell.newsImage.image = image

                
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsListTableViewCell, for: indexPath) as! NewsListTableViewCell
            
            // Binding data to the table view cell
            cell.configure(with: article)
            
            
            cell.loadImage(from: article.urlToImage, viewModel: vm) { image in
                
                // In case of null value for image
                guard let image = image else {
                    cell.newsImage.image = UIImage(named: "newsImage")
                    return
                }
                cell.newsImage.image = image
            }
            
            return cell
        }
    }
    
    // Navigate to webview to display the whole news
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webView = storyboard.instantiateViewController(withIdentifier: "NewsDetailsViewController") as! NewsDetailsViewController
        
        // passing image URL to the webView
        webView.urlString = newsData?.articles?[indexPath.row].url ?? ""
        self.navigationController?.pushViewController(webView, animated: true)
        
        
    }
    
    
}

