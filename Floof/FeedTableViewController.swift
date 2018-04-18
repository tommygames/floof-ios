//
//  FeedTableViewController.swift
//  Floof
//
//  Created by Tommy Mallow on 4/10/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import AVKit

class FeedTableViewController: UITableViewController {
    
    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var videoFiles = [PFFile]()
    var videoUrls = [String]()
    
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var firstLoad = true
    var visibleIP : IndexPath?
    
    var screenRect = CGRect()
    var screenWidth = CGFloat()
    var screenHeight = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenRect = UIScreen.main.bounds
        screenWidth = screenRect.size.width
        screenHeight = screenRect.size.height
        
        // initialized to first indexpath
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        let query = PFUser.query()
        query?.whereKey("Username", notEqualTo: PFUser.current()?.username)
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.users[user.objectId!] = user.username!
                        
                    }
                    
                }
                
            }
            
            
            let getFollowedUsersQuery = PFQuery(className: "Following")
            getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.current()?.objectId)
            getFollowedUsersQuery.findObjectsInBackground(block: { (objects, error) in
                
                if let followers = objects {
                    
                    for follower in followers {
                        
                        if let followedUser = follower["following"] {
                            
                            let query = PFQuery(className: "Post")
                            
                            query.whereKey("userid", equalTo: followedUser)
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let posts = objects {
                                    
                                    for post in posts {
                                        
                                        //****** need to add if let statements for optional handling *******
                                        //****** should add chronological order to images
                                        
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
//                                        self.videoFiles.append(post["videoFile"] as! PFFile)
                                        self.videoUrls.append((post["videoFile"] as! PFFile).url!)
                                        
                                        self.tableView.reloadData()
                                        
                                    }
                                    
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                }
                
                
                
            })
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        //Thats it, just provide the URL from here, it will change with didSet Method in your custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! FeedTableViewCell
            if !videoUrls[indexPath.row].isEmpty {
                
                let videoUrlString = self.videoUrls[indexPath.row]
                    let videoUrl = NSURL(string: videoUrlString)!
                    cell.videoPlayerItem = AVPlayerItem.init(url: videoUrl as URL)
                
            } else {
                print("Error: No video url was found.")
        }
        
        cell.comment.text = comments[indexPath.row]
        cell.userInfo.text = usernames[indexPath.row]
        tableView.rowHeight = screenHeight - 70
        
        
        return cell
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = tableView.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = tableView.cellForRow(at: ip) as? FeedTableViewCell{
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? FeedTableViewCell{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let cellRect = tableView.rectForRow(at: (indexPaths?[i])!)
                let intersect = cellRect.intersection(tableView.bounds)
                //                currentHeight is the height of the cell that
                //                is visible
                let currentHeight = intersect.height
                print("\n \(currentHeight)")
                let cellHeight = (cells[i] as AnyObject).frame.size.height
                //                0.20 is percent of cell that is visible
                if currentHeight > (cellHeight * 0.20){
                    if visibleIP != indexPaths?[i]{
                        visibleIP = indexPaths?[i]
//                        print ("visible = \(indexPaths?[i])")
                        if let videoCell = cells[i] as? FeedTableViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? FeedTableViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                        
                    }
                }
            }
        }
    }
    
    func playVideoOnTheCell(cell : FeedTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : FeedTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? FeedTableViewCell {
            videoCell.stopPlayback()
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
