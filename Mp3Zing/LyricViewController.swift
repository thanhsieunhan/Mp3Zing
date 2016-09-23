//
//  LyricViewController.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/14/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

extension UILabel {
    func setTextWithWordTypeAnimation(typedText: UILabel, characterInterval: Double) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            let attributedString = NSMutableAttributedString(string:typedText.text!)
            for i in 0...typedText.text!.characters.count{
                
                dispatch_async(dispatch_get_main_queue()) {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor() , range:  NSRange(location: 0, length: i) )
                    typedText.attributedText = attributedString
                    
                    
                }
                NSThread.sleepForTimeInterval(characterInterval)
                
                
                
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor() , range:  NSRange(location: 0, length: typedText.text!.characters.count))
                typedText.attributedText = attributedString
            }
        }
    }
}



class LyricViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var pageControler: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var lyricTabeView : UITableView!
    var localTableView : UITableView!
    var listSongs = [Song]()
    var first = false
    let audioPlayer = AudioPlayer.sharedInstance
    var currentPage = 0
    var indexPath = NSIndexPath()
    var value = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControler.currentPage = currentPage
        pageControler.numberOfPages = 3
        scrollView.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        localTableView.reloadData()
    }
    
    var i = 0
    func autoScroll(){
        let currentTime =  Double(audioPlayer.currentTime)
        let lyricTime = stringToDouble(audioPlayer.lyric[i].time)
        
        if currentTime >= lyricTime {
            // lấy thời gian giữa 2 lyric
            let durationTime = stringToDouble(audioPlayer.lyric[i+1].time) - stringToDouble(audioPlayer.lyric[i].time)
            
            // number Of Section
            let nos = lyricTabeView.numberOfSections
            let currentPath : NSIndexPath = NSIndexPath(forItem: i, inSection: nos - 1)
            let cell = lyricTabeView.cellForRowAtIndexPath(currentPath)
            let lengthText = audioPlayer.lyric[i].content == "" ? 3 : Double(audioPlayer.lyric[i].content.characters.count)
            var length = 0.0
            if lengthText < 5 {
                length = lengthText * 1.1
            } else if lengthText < 10 && lengthText > 5{
                length = lengthText * 3
            } else if lengthText < 15 && lengthText > 10{
                length = lengthText * 4
            } else {
                length = lengthText * 5
            }
            
            let characterInterval = durationTime / length
            cell?.textLabel?.setTextWithWordTypeAnimation((cell?.textLabel)!, characterInterval: characterInterval)
            i = i + 1
            
            lyricTabeView.scrollToRowAtIndexPath(currentPath , atScrollPosition: .Middle, animated: true)
            lyricTabeView.selectRowAtIndexPath(currentPath, animated: false, scrollPosition: .Middle)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if (!first){
            first = true
            
            let widthView = scrollView.frame.size.width
            let heightView = scrollView.frame.size.height
            
            scrollView.contentSize = CGSize(width: widthView * CGFloat(3), height: 10)
            
            scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * widthView, y: 0)
            
            for i in 0..<3 {
                let masterTV = UITableView(frame: CGRect(x: widthView * CGFloat(i), y: 17, width: widthView, height: heightView-86))
                
                masterTV.tag = i + 100
                masterTV.dataSource = self
                masterTV.delegate = self
                
                
                masterTV.showsHorizontalScrollIndicator = false
                masterTV.separatorColor = UIColor.clearColor()
                scrollView.addSubview(masterTV)
                scrollView.decelerationRate = 1
                
            }

        }
        for i in scrollView.subviews {
            if i.tag == 101 {
                lyricTabeView = i as! UITableView
                lyricTabeView.delegate = self
            } else if i.tag == 100 {
                localTableView = i as! UITableView
            }
            
        }
        
        getData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 101 {
            return audioPlayer.lyric.count
        } else if tableView.tag == 100 {
            return listSongs.count
        }
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == 101 {
            return 50
        }
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView.tag == 101 {
            var content = ""
            if audioPlayer.lyric[indexPath.row].content == "" {
                content = "..."
            } else {
                content = audioPlayer.lyric[indexPath.row].content
            }
            cell.textLabel?.text = content
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.font = UIFont.systemFontOfSize(20)
            
            
        } else if tableView.tag == 100 {
            
            cell.imageView?.image = listSongs[(indexPath as NSIndexPath).row].thumbnail
            cell.textLabel?.text = listSongs[(indexPath as NSIndexPath).row].title
            
        } else
        {
            cell.textLabel?.text = "Thanh"
            cell.textLabel?.highlighted = false
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 100 {
            let audioPlay = AudioPlayer.sharedInstance
            let titleSong = listSongs[indexPath.row].title
            audioPlay.pathString = listSongs[indexPath.row].sourceLocal
            audioPlay.titleSong = "\(titleSong) Ca si: \(listSongs[(indexPath as NSIndexPath).row].artistName)"
            
            audioPlay.lyric = getLyric(titleSong)
            audioPlay.setupAudio()
            
            lyricTabeView.reloadData()
            _ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(LyricViewController.autoScroll), userInfo: nil, repeats: true)
            NSNotificationCenter.defaultCenter().postNotificationName("setupObserveAudio", object: nil)
        }
        
        i = 0
    }
    
    
    func stringToDouble(string : String) -> Double {
        let string1 = string.componentsSeparatedByString(":")
        let min = Double(string1[0])
        
        let string2 = string1[1].componentsSeparatedByString(".")
        let sec = Double(string2[0])
        let msec = Double(string2[1])! * 0.01
        
        return min! * 60 + sec! + msec
    }
    
    // ====================//
    
    func getData()
    {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
            do {
                let folders = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
                for folder in folders {
                    if folder != ".DS_Store" {
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        let title = info!["title"] as! String
                        let artisName = info!["artisName"] as! String
                        let thumbnailPath = info!["localThumbnail"] as! String
                        let sourceLocal = dir + "/\(title)/\(title).mp3"
                        let localThumbnail = dir + thumbnailPath
                        let lyric = info!["lyrics_file"] as! String
                        let currentSong = Song(title: title, artistName: artisName, localThumbnail: localThumbnail, localSource: sourceLocal, lyric: lyric)
                        listSongs.append(currentSong)
                    }
                }
                localTableView.reloadData()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func getLyric(title: String) -> [Lyric]{
        var lyricList = [Lyric]()
        
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            let file = dir + "/\(title)/lyrics_file.txt"
            let data = try! String(contentsOfFile: file)
            
            var myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            // xoá các giá trị "" thừa
            for i in myStrings {
                if i == "" {
                    myStrings.removeAtIndex(myStrings.indexOf(i)!)
                }
            }
            
            for i in myStrings{
                if i.hasPrefix("[length:") {
                    print(i)
                }
                if myStrings[5].hasPrefix("[id:") {
                    if myStrings.indexOf(i) > 5 {
                        lyricList.append(appendLyric(i))
                    }
                } else {
                    if myStrings.indexOf(i) > 4 {
                        lyricList.append(appendLyric(i))
                    }
                    
                }
            }
            
        }
        return lyricList
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1)
        if (currentPage != page) {
            currentPage = page
        }
        
        pageControler.currentPage = page
    }
    
    func appendLyric(i : String) -> Lyric {
        
        var word = i.componentsSeparatedByString("]")
        var time = word[0]
        
        // xoá kí tự đầu tiên. xoá kí tự "["
        time.removeAtIndex(time.startIndex)
        let content: String = word[1]
        
        return Lyric(time: time, content: content)
    }
    
}
