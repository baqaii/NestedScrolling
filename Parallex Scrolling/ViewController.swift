//
//  ViewController.swift
//  Parallex Scrolling
//
//  Created by bibek on 8/25/16.
//  Copyright © 2017 Daniyal All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var childScrollView: UIScrollView {
        return tableView
    }
    
    let person: [String] = ["Bean", "Roy",  "Beard", "Charles A. Beaumont and Fletcher", "Beck", "Glenn", "Becker", "Carl", "Beckett", "Samuel", "Beddoes", "Mick", "Beecher", "Henry Ward", "Beethoven", "Ludwig van", "Bean", "Roy",  "Beard", "Charles A. Beaumont and Fletcher", "Beck", "Glenn", "Becker", "Carl", "Beckett", "Samuel", "Beddoes", "Mick", "Beecher", "Henry Ward", "Beethoven", "Ludwig van"]
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentScrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return person.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "#\(indexPath.row)"
        cell.detailTextLabel?.text = person[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .green
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // determining whether scrollview is scrolling up or down
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        
        // maximum contentOffset y that parent scrollView can have
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height
        print("ParentViewMaxContentOffset : \(parentViewMaxContentYOffset)")
        // if scrollView is going upwards
        if goingUp! {
            print("Going Up")
            // if scrollView is a child scrollView
            
            if scrollView == childScrollView {
                print("TableViewScroll")
                // if parent scroll view is't scrolled maximum (i.e. menu isn't sticked on top yet)
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    print("ParentScrollViewContentOffSetY : \(parentScrollView.contentOffset.y)")
                    // change parent scrollView contentOffset y which is equal to minimum between maximum y offset that parent scrollView can have and sum of parentScrollView's content's y offset and child's y content offset. Because, we don't want parent scrollView go above sticked menu.
                    // Scroll parent scrollview upwards as much as child scrollView is scrolled
                    // Sometimes parent scrollView goes in the middle of screen and stucks there so max is used.
                    parentScrollView.contentOffset.y = max(min(parentScrollView.contentOffset.y + childScrollView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    
                    // change child scrollView's content's y offset to 0 because we are scrolling parent scrollView instead with same content offset change.
                    childScrollView.contentOffset.y = 0
                }
            }
        }
            // Scrollview is going downwards
        else {
            
            if scrollView == childScrollView {
                // when child view scrolls down. if childScrollView is scrolled to y offset 0 (child scrollView is completely scrolled down) then scroll parent scrollview instead
                // if childScrollView's content's y offset is less than 0 and parent's content's y offset is greater than 0
                if childScrollView.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    
                    // set parent scrollView's content's y offset to be the maximum between 0 and difference of parentScrollView's content's y offset and absolute value of childScrollView's content's y offset
                    // we don't want parent to scroll more that 0 i.e. more downwards so we use max of 0.
                    parentScrollView.contentOffset.y = max(parentScrollView.contentOffset.y - abs(childScrollView.contentOffset.y), 0)
                }
            }
            
            // if downward scrolling view is parent scrollView
            if scrollView == parentScrollView {
                // if child scrollView's content's y offset is greater than 0. i.e. child is scrolled up and content is hiding up
                // and parent scrollView's content's y offset is less than parentView's maximum y offset
                // i.e. if child view's content is hiding up and parent scrollView is scrolled down than we need to scroll content of childScrollView first
                if childScrollView.contentOffset.y > 0 && parentScrollView.contentOffset.y < parentViewMaxContentYOffset {
                    // set if scrolling is due to parent scrolled
                    childScrollingDownDueToParent = true
                    // assign the scrolled offset of parent to child not exceding the offset 0 for child scroll view
                    childScrollView.contentOffset.y = max(childScrollView.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    // stick parent view to top coz it's scrolled offset is assigned to child
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}
