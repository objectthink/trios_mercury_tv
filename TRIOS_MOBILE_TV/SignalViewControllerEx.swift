//
//  SignalViewControllerEx.swift
//  TRIOS_MOBILE_TV
//
//  Created by stephen eshelman on 10/4/15.
//  Copyright © 2015 objectthink.com. All rights reserved.
//

import UIKit

class SignalViewControllerEx: UIViewController, UITableViewDataSource, UITableViewDelegate
{
   @IBOutlet var _segmentedControl: UISegmentedControl!
   @IBOutlet var _listView: UIView!
   @IBOutlet var _chartView: UIView!
   
   var _tableView:UITableView!
   
   var _signals:[Float]?
   
   var instrument: MercuryInstrument?
      {
      didSet
      {
         // Update the view.
         //self.configureView()
      }
   }

   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      // Do any additional setup after loading the view.
      
      _listView.hidden = false
      _chartView.hidden = true
   }
   
   @IBAction func indexChanged(sender: UISegmentedControl)
   {
      switch _segmentedControl.selectedSegmentIndex
      {
      case 0:
         _listView.hidden = false
         _chartView.hidden = true
      case 1:
         _listView.hidden = true
         _chartView.hidden = false
      default:
         break;
      }
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
   {
      if let vc = segue.destinationViewController as? UITableViewController
         where segue.identifier == "EmbedSegue"
      {
         vc.tableView.dataSource = self
         vc.tableView.delegate = self
      }
   }
   
   override func didReceiveMemoryWarning()
   {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int
   {
      // #warning Incomplete implementation, return the number of sections
      return 1
   }
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
   {
      // #warning Incomplete implementation, return the number of rows
      return (_signals?.count)!
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
   {
      let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath)
      
      let procedure = MercuryGetProcedureResponse()
      let s = procedure.signalToString(Int32(indexPath.row))
      
      let t = NSString(format: "\t%@ \t%.2f", s as String, self._signals![indexPath.row])
      
      // Configure the cell...
      cell.textLabel?.text = t as String
      //cell.textLabel?.text = "777"
      
      return cell
   }
   
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
   {
      self.performSegueWithIdentifier("showSignalChooser", sender: tableView)
   }
   
   func stat(message: NSData!, withSubcommand subcommand: uint)
   {
      print("stat in signal view")
      
      dispatch_async(dispatch_get_main_queue(),
         { () -> Void in
            if subcommand == 0x00020002
            {
               self._signals?.removeAll()
               
               let count = message.length/4
               
               for i in 0...count-1
               {
                  let signal = self.instrument?.floatAtOffset(UInt(i*4), inData: message)
                  
                  self._signals?.append(signal!)
               }
            }
            
            self._tableView.reloadData()
      })
   }
   
   /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
   
}
