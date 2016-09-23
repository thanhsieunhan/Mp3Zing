//
//  TableViewOnline.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/6/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

// trả về mảng Folder. và lấy cái đầu tiên

let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first


class TableViewOnline: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var listSongs = [Song]()
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        getData()
        
        print(kDOCUMENT_DIRECTORY_PATH)
        
    }
    
    
    func getData()
    {
        let data = NSData(contentsOfURL: NSURL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html")!)
        //        print(String(data: data!, encoding: NSUTF8StringEncoding))
        let doc = TFHpple(HTMLData: data)
        if let elements = doc.searchWithXPathQuery("//h3[@class='title-item']/a") as? [TFHppleElement] {
            //
            for element in elements {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let id = self.getID(element.objectForKey("href"))
                    let url = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
                    var stringData = ""
                    do {
                        stringData = try String(contentsOfURL: url!)
                    }
                    catch let  error as NSError
                    {
                        print(error)
                    }
                    
                    let json = self.convertStringToDictionary(stringData)
                    if (json != nil){
                        self.addSongToList(json!)
                    }
                })
                
            }
            
            
        }
    }
    
    func getID(path: NSString) -> String
    {
        // stringByDeletingPathExtension xoa .html, .exe, ....
        let id = (path.lastPathComponent as NSString).stringByDeletingPathExtension
        return id
        
    }
    
    func convertStringToDictionary(string: String) -> [String : AnyObject]?
    {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject]
                return json!
            }  catch {
                print("Error")
            }
        }
        
        return nil
    }
    
    func addSongToList(json: [String: AnyObject]){
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        let lyric = json["lyrics_file"] as! String
        
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, lyric: lyric)
        
        listSongs.append(currentSong)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.myTableView.reloadData()
        }
        
    }
    
    //UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        
        cell.imageView?.image = listSongs[(indexPath as NSIndexPath).row].thumbnail
        cell.textLabel?.text = listSongs[(indexPath as NSIndexPath).row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .Normal, title: "Download") { (action, index) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.downloadSong(indexPath.row)
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.myTableView.reloadData()
            }
        }
        edit.backgroundColor = UIColor.redColor()
        return [edit]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSongs[(indexPath as NSIndexPath).row].sourceOnline
        audioPlay.titleSong = "\(listSongs[(indexPath as NSIndexPath).row].title) Ca si: \(listSongs[(indexPath as NSIndexPath).row].artistName)"
        
        audioPlay.setupAudio()
        
        NSNotificationCenter.defaultCenter().postNotificationName("setupObserveAudio", object: nil)
    }
    
    
    
    // download
    
    func downloadSong(index: Int)
    {
        let dataSong = NSData(contentsOfURL: NSURL(string: listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("error")
            }
            
            
            // ghi bai hat
            writeDataToPath(dataSong! as NSObject, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
            
            // ghi ra thong tin bai hat
            writeInfoSong(listSongs[index], path: pathToWriteSong)
        }
    }
    
    func writeInfoSong(song: Song, path: String){
        let dicData = NSMutableDictionary()
        dicData.setValue(song.title, forKey: "title")
        dicData.setValue(song.artistName, forKey: "artisName")
        dicData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dicData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dicData.setValue(song.lyric, forKey: "lyrics_file")
        
        //write info
        
        writeDataToPath(dicData, path: "\(path)/info.plist")
        
        
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!) as NSData
        writeDataToPath(dataThumbnail as NSObject, path: "\(path)/thumbnail.png")
        
        //        let lyricData = NSData(contentsOfURL: NSURL(string: song.lyric)!)
        var returnString = "Không có lời. Ahihi"
        if song.lyric != "" {
            let url = NSURL(string: song.lyric)!
            //            returnString = try! String(contentsOf: url, encoding: NSUTF8StringEncoding)
            returnString = try! String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        }
        
        // download + write to file
        
        do {
            
            try returnString.writeToFile("\(path)/lyrics_file.txt", atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print("xyz")
        }
    }
    
    func writeDataToPath(data: NSObject, path: String) {
        if let dataToWrite = data as? NSData {
            dataToWrite.writeToFile(path, atomically: true)
        } else if let dataInfo = data as? NSDictionary {
            dataInfo.writeToFile(path, atomically: true)
        }
        
    }
    
    
}
