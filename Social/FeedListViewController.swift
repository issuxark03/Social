//
//  FeedListViewController.swift
//  Social
//
//  Created by Yongwoo Yoo on 2022/05/18.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseFirestore

class FeedListViewController: UITableViewController {
//    var ref: DatabaseReference! //Firebase realtime database
    var db = Firestore.firestore()
    
    var feedList: [Feed] = [] //initialize

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView Cell Register
        let feedNibName = UINib(nibName: "FeedListCell", bundle: nil)
        tableView.register(feedNibName, forCellReuseIdentifier: "FeedListCell")
        let adNibName = UINib(nibName: "ADTableViewCell", bundle: nil)
        tableView.register(adNibName, forCellReuseIdentifier: "ADTableViewCell")
        
        //Firestore 읽기
        db.collection("feedList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("ERROR firestore fetching document \(String(describing: error))")
                return
            }
            //json 파싱
            self.feedList = documents.compactMap{ doc -> Feed? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let feed = try JSONDecoder().decode(Feed.self, from: jsonData)
                    return feed
                } catch let error {
                    print("ERROR JSON Parsing \(error)")
                    return nil
                }
             }.sorted{ $0.id < $1.id } //id순으로 정렬
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
   
}

//tableView Delegate
extension FeedListViewController {
    
    //셀의 갯수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    //셀 설정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //3번째마다 광고 셀
        if ((indexPath.row+1)%3 == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ADTableViewCell", for: indexPath) as? ADTableViewCell else { return UITableViewCell() }
            
            return cell
        //피드 셀
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListCell", for: indexPath) as? FeedListCell else { return UITableViewCell() }
            
            cell.detailLabel.text = "\(feedList[indexPath.row].detail)"
            cell.likeCountLabel.text = "\(feedList[indexPath.row].likeCount)"
            cell.commentCountLabel.text = "댓글 \(feedList[indexPath.row].commentCount)개"
            
            guard let isLike = feedList[indexPath.row].isLike else { return UITableViewCell() }
            
            if isLike {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }

            let imageUrl = URL(string: feedList[indexPath.row].cardImageURL)
            
            if imageUrl != nil {
                cell.cardImageView.kf.setImage(with: imageUrl)
            }else {
                cell.cardImageView.isHidden = true
                cell.cardImageView.frame.size = CGSize(width: 0, height: 0)
            }
            
            return cell
        }
        
    }
    
    //셀의 높이 delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath.row+1)%3 == 0) {
            return 80
        }else{
            let imageUrl = URL(string: feedList[indexPath.row].cardImageURL)
            if imageUrl != nil {
                return 320
            }else {
                return 150
            }
            
        }
        
    }
    //셀 선택시 action
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //광고 셀
        if ((indexPath.row+1)%3 == 0) {
            //광고창 이동 alert창
            let alertController = UIAlertController(title: "광고", message: "외부 브라우저로 연결됩니다. 계속 하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in //확인버튼 누를시 동작
                if let url = URL(string: "https://www.google.com") {
                    UIApplication.shared.open(url)
                }
            }))
            alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))

            self.present(alertController, animated: true, completion: nil)
            
        //피드 셀 선택시
        }else{
            //상세화면 전달
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as? FeedDetailViewController else { return }
            
            detailViewController.feed = feedList[indexPath.row]
            self.show(detailViewController, sender: nil)

        }
        
    }
    
    //셀 수정가능여부
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
