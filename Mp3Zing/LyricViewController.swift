//
//  LyricViewController.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/14/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

extension UILabel {
    func setTextWithWordTypeAnimation(typedText: UILabel, characterInterval: NSTimeInterval = 0.25) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            let attributedString = NSMutableAttributedString(string:typedText.text!)
            for i in 0...typedText.text!.characters.count{
                
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor() , range:  NSRange(location:0,length:i) )
                
                dispatch_async(dispatch_get_main_queue()) {
                    typedText.attributedText = attributedString
                }
                NSThread.sleepForTimeInterval(characterInterval)
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
    
    var i = 0
    func autoScroll(){
        let currentTime =  Double(audioPlayer.currentTime)
        let lyricTime = stringToDouble(audioPlayer.lyric[i].time)
        
        if currentTime >= lyricTime {
            // lấy thời gian giữa 2 lyric
            let durationTime = stringToDouble(audioPlayer.lyric[i+1].time) - stringToDouble(audioPlayer.lyric[i].time)
            
            // number Of Section
            let nos = lyricTabeView.numberOfSections
            let lastPath : NSIndexPath = NSIndexPath(forItem: i, inSection: nos - 1)
            i = i + 1
            lyricTabeView.scrollToRowAtIndexPath(lastPath , atScrollPosition: .Middle, animated: true)
            lyricTabeView.selectRowAtIndexPath(lastPath, animated: false, scrollPosition: .Middle)
            let cell = lyricTabeView.cellForRowAtIndexPath(lastPath)
            let characterInterval = durationTime / Double((cell?.textLabel?.text?.characters.count)!)
            cell?.textLabel?.setTextWithWordTypeAnimation((cell?.textLabel)!, characterInterval: characterInterval)
        }
    }
    
    
    override func viewDidLayoutSubviews() {

        if (!first){
            first = true

            let widthView = scrollView.frame.size.width
            let heightView = CGFloat(view.frame.size.height)
            scrollView.contentSize = CGSize(width: widthView * CGFloat(3), height: 0)
            
            scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * widthView, y: 0)
            
            for i in 0..<3 {
                let masterTV = UITableView(frame: CGRect(x: widthView * CGFloat(i), y: 17, width: scrollView.frame.size.width, height: heightView ))
                print(masterTV.frame)
                masterTV.tag = i + 100
                masterTV.dataSource = self
                masterTV.delegate = self
                masterTV.backgroundColor = UIColor.redColor()
                
                masterTV.showsVerticalScrollIndicator = false
                masterTV.showsHorizontalScrollIndicator = false
                masterTV.separatorColor = UIColor.clearColor()
                scrollView.addSubview(masterTV)
            }
            
        }
        for i in scrollView.subviews {
            if i.tag == 101 {
                lyricTabeView = i as! UITableView
            } else if i.tag == 100 {
                localTableView = i as! UITableView
            }
            
        }
        getData()
        _ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(LyricViewController.autoScroll), userInfo: nil, repeats: true)

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 101 {
            return audioPlayer.lyric.count
        } else if tableView.tag == 100 {
            return listSongs.count
        }
        
        
        
        return 3
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
            cell.selectionStyle = .Blue
            
        }
        else
        {
            cell.textLabel?.text = "Thanh"
            cell.textLabel?.highlighted = false
        }
        cell.textLabel?.backgroundColor = UIColor.redColor()
        
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
            
            localTableView.reloadData()
            
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
                if myStrings.indexOf(i) > 4 {
                    
                    // tách thành 2 chuỗi time và content đc chia bằng "]"
                    var word = i.componentsSeparatedByString("]")
                    var time = word[0]
                    
                    // xoá kí tự đầu tiên. xoá kí tự "["
                    time.removeAtIndex(time.startIndex)
                    let content: String = word[1]
                    
                    lyricList.append(Lyric(time: time, content: content))
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
    
    
}
