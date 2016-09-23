//
//  TableViewLocal.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/8/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

class TableViewLocal: UIViewController {
//, UITableViewDataSource, UITableViewDelegate{

//    @IBOutlet weak var myTableView: UITableView!
//    var listSongs = [Song]()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        myTableView.delegate = self
//        myTableView.dataSource = self
//        getData()
//    }
//    
//    func getData()
//    {
//        listSongs.removeAll()
//        if let dir = kDOCUMENT_DIRECTORY_PATH
//        {
//            do {
//                let folders = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
//                for folder in folders {
//                    if folder != ".DS_Store" {
//                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
//                        let title = info!["title"] as! String
//                        let artisName = info!["artisName"] as! String
//                        let thumbnailPath = info!["localThumbnail"] as! String
//                        let sourceLocal = dir + "/\(title)/\(title).mp3"
//                        let localThumbnail = dir + thumbnailPath
//                        let lyric = info!["lyrics_file"] as! String
//                        let currentSong = Song(title: title, artistName: artisName, localThumbnail: localThumbnail, localSource: sourceLocal, lyric: lyric)
//                        listSongs.append(currentSong)
//                    }
//                }
//                myTableView.reloadData()
//            } catch let error as NSError {
//                print(error)
//            }
//        }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(animated)
//        getData()
//        myTableView.reloadData()
//    }
//    
//    // UITableView
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return listSongs.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//        
//        cell.imageView?.image = listSongs[(indexPath as NSIndexPath).row].thumbnail
//        cell.textLabel?.text = listSongs[(indexPath as NSIndexPath).row].title
//    
//
//        cell.selectionStyle = .Blue
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let edit = UITableViewRowAction(style: .Normal, title: "DELETE") { (action, index) in
//            self.removeSongAtIndex((indexPath as NSIndexPath).row)
//            self.myTableView.reloadData()
//            
//        }
//        edit.backgroundColor = UIColor.redColor()
//        return [edit]
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let audioPlay = AudioPlayer.sharedInstance
//        let titleSong = listSongs[indexPath.row].title
//        audioPlay.pathString = listSongs[indexPath.row].sourceLocal
//        audioPlay.titleSong = "\(titleSong) Ca si: \(listSongs[(indexPath as NSIndexPath).row].artistName)"
//        
//        audioPlay.lyric = getLyric(titleSong)
//        audioPlay.setupAudio()
//
//        myTableView.reloadData()
//        
//        NSNotificationCenter.defaultCenter().postNotificationName("setupObserveAudio", object: nil)
//        
//    }
//    
//    // xoá theo chỉ số
//    func removeSongAtIndex(index: Int) {
//        if let dir = kDOCUMENT_DIRECTORY_PATH {
//            do {
//                let path = dir + "/\(listSongs[index].title)"
//                try NSFileManager.defaultManager().removeItemAtPath(path)
//                
//                listSongs.removeAtIndex(index)
//                self.myTableView.reloadData()
//            } catch let error as NSError {
//                print(error)
//            }
//        }
//    }
//    
//    
//    // lấy lyric theo tên bài hát trả về mảng
//    func getLyric(title: String) -> [Lyric]{
//        var lyricList = [Lyric]()
//        
//        if let dir = kDOCUMENT_DIRECTORY_PATH {
//            let file = dir + "/\(title)/lyrics_file.txt"
//            let data = try! String(contentsOfFile: file)
//            
//            var myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
//            
//            // xoá các giá trị "" thừa
//            for i in myStrings {
//                if i == "" {
//                    myStrings.removeAtIndex(myStrings.indexOf(i)!)
//                }
//            }
//            
//            for i in myStrings{
//                if myStrings.indexOf(i) > 4 {
//                    
//                    // tách thành 2 chuỗi time và content đc chia bằng "]"
//                    var word = i.componentsSeparatedByString("]")
//                    var time = word[0]
//                    
//                    // xoá kí tự đầu tiên. xoá kí tự "["
//                    time.removeAtIndex(time.startIndex)
//                    let content: String = word[1]
//
//                    lyricList.append(Lyric(time: time, content: content))
//                }
//            }
//
//        }
//        return lyricList
//    }
//    
//    
//    
    
}
