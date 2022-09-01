//
//  FeedDetailViewController.swift
//  Social
//
//  Created by Yongwoo Yoo on 2022/05/18.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseFirestore

class FeedDetailViewController: UIViewController {
        
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    
    var keyHeight: CGFloat?
    var feed: Feed?
    var commentList: [Comment] = [] //initialize
    var indexPath: IndexPath?
    var db = Firestore.firestore()
    //var ref: DatabaseReference! //Firebase realtime database
    
     override func viewDidLoad() {
         super.viewDidLoad()
         self.configureView()
         self.commentTableView()
         self.configureInputField()
         self.commentButton.isEnabled = false //등록버튼 비활성화(초기값)
         
         //키보드 보이기/숨기기시 작동하는 Observer
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
    
    //화면 설정
    private func configureView() {
        guard let feed = self.feed else { return } //optional binding
        self.detailLabel.text = feed.detail
        self.likeCountLabel.text = String(feed.likeCount)
        
        let imageUrl = URL(string: feed.cardImageURL)
        
        if imageUrl != nil {
            self.cardImageView.kf.setImage(with: imageUrl)
        }else {
            self.cardImageView.isHidden = true
            self.cardImageView.frame.size = CGSize(width: 0, height: 0)
        }
        
        guard let isLike = self.feed?.isLike else { return }
        
        if isLike {
            self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
   
    }
    
    //댓글 TableView 설정
    private func commentTableView() {
        tableView.dataSource = self
        let commentNibName = UINib(nibName: "CommentCell", bundle: nil)
        tableView.register(commentNibName, forCellReuseIdentifier: "CommentCell")
        
        guard let cardID = self.feed?.id else { return }
        let path = db.collection("feedList")

        path.getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
            } else {
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents { 
                    if document.documentID == "card\(cardID)" {
                        // 서버에 저장된 딕셔너리 데이터를 가져온다.
                        guard let commentCount = self.feed?.commentCount else { return }
                        
                        //값이 있다면 초기화함 (리로드시 중복표시 방지)
                        if !(self.commentList.isEmpty) {
                            self.commentList.removeAll()
                        }
                         
                        //댓글의 갯수만큼 commentList에 append
                        for i in 0...commentCount {
                            guard let data = document["comment\(i)"] as? [String : Any] else { return }
                            guard let id = data["id"] as? Int else { return }
                            guard let name = data["name"] as? String else { return }
                            guard let content = data["content"] as? String else { return }
                            
                            let element = Comment(id: id, name: name, content: content)
                            self.commentList.append(element)
                            self.commentList = self.commentList.sorted(by: {$0.id < $1.id }) //id순으로 정렬
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        }
    }
        
     
     
    //LIKE 버튼 터치시
    @IBAction func tabLikeButton(_ sender: Any) {
        guard let cardID = self.feed?.id else { return }
        guard let likeCount = self.feed?.likeCount else { return }
        guard let isLike = self.feed?.isLike else { return }
        
        let isLikeTobe = !(isLike) //바뀔 좋아요 여부
        var likeCountTobe = likeCount //바뀔 좋아요 갯수
        
        self.feed?.isLike = isLikeTobe
        
        if isLikeTobe { //false -> true
            self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeCountTobe = likeCount + 1
        }else{ //true -> false
            self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeCountTobe = likeCount - 1
        }
        //좋아요 갯수
        self.likeCountLabel.text = String(likeCountTobe)
        
        //FireStore 값 변경
        db.collection("feedList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
            guard let document = snapshot?.documents.first else {
                print("ERROR Firestore fetching document")
                return
            }
            
            document.reference.updateData(["isLike":isLikeTobe])
            document.reference.updateData(["likeCount":likeCountTobe])
            self.feed?.likeCount = likeCountTobe
        }
    }
     
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) //제목 text가 입력될때마다 호출
        self.contentTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) //날짜가 변경될때 호출
    }
    
    //텍스트필드가 변할때 호출되는 selector
    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    //빈화면 누를때 실행됨
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //편집모드 종료
    }
    
    //등록버튼 활성화여부 판단
    private func validateInputField() {
        self.commentButton.isEnabled = !(self.nameTextField.text?.isEmpty ?? true) && !(self.contentTextField.text?.isEmpty ?? true) //모든 inputfield가 비어있지 않으면 enable
    }
    
    //댓글 확인후 호출
    private func finishedCommentRegi() {
        //입력필드 초기화
        self.nameTextField.text = ""
        self.contentTextField.text = ""
        self.commentButton.isEnabled = false //등록버튼 비활성화(초기값)
        self.view.endEditing(true) //편집모드 종료
    }
        
    //키보드가 나타날때 (화면가림 방지)
    @objc func keyboardWillShow(_ sender: Notification) {
       let userInfo:NSDictionary = sender.userInfo! as NSDictionary
       let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
       let keyboardRectangle = keyboardFrame.cgRectValue
       let keyboardHeight = keyboardRectangle.height
       keyHeight = keyboardHeight

        self.view.frame.origin.y = -keyboardHeight
    }
    
    //키보드가 사라질때
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 //뷰 원상복구
    }
    
    
    //댓글 등록확인 버튼 클릭시
    @IBAction func tabCommentButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "댓글", message: "댓글을 등록하시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in //확인버튼 누를시 동작
            self.commentRegi()
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func commentRegi() {
        guard let cardID = self.feed?.id else { return }
        guard let commentCount = self.feed?.commentCount else { return }
        guard let name = self.nameTextField.text else { return }
        guard let content = self.contentTextField.text else { return }
        //comment 추가하기
        let path = db.collection("feedList").document("card\(cardID)")
        db.collection("feedList").document("card\(cardID)")
        // 딕셔너리(맵)에 데이터 추가
        path.updateData(["comment\(commentCount)" : ["id": Int(commentCount), "name" : "\(name)", "content" : "\(content)"]])
                
        let commentCountTobe = commentCount + 1
        // 댓글 카운트 증가
        db.collection("feedList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
            guard let document = snapshot?.documents.first else {
                print("ERROR Firestore fetching document")
                return
            }
            
            document.reference.updateData(["commentCount":commentCountTobe])
            self.feed?.commentCount = commentCountTobe //댓글카운트 증가
            self.finishedCommentRegi() //종료후 호출
            self.commentTableView() //reload
            
        }
    }
    
}

//TableView DataSource
extension FeedDetailViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //debugPrint("카운트 \(commentList.count)")
        return self.commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else { return UITableViewCell() }
        cell.nameLabel.text = "\(commentList[indexPath.row].name)"
        cell.contentLabel.text = "\(commentList[indexPath.row].content)"
        return cell
    }
    
}

extension FeedDetailViewController : UITextViewDelegate {
    //textview의 text가 입력될때마다 호출되는 delegate
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }}
