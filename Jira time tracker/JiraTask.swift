//
//  JiraTask.swift
//  Jira time tracker
//
//  Created by Denis Kudinov on 16/11/2016.
//  Copyright © 2016 Denis Kudinov. All rights reserved.
//

import Foundation

enum JiraTaskStatus {
  case inProgress
  case resolved
  case closed
  case open
}

class JiraTask {
  
  var URL: URL?
  var title: String?
  var shortID: String?
  var estimatedTime: TimeInterval?
  var loggedTime: TimeInterval?
  var currentSessionLoggedTime: TimeInterval?
  var status: JiraTaskStatus?
  
  class func mockedTask() -> JiraTask {
    let task = JiraTask()
    task.URL = NSURL(string: "http://www.jira.com/") as URL?
    task.title = "..."
    task.shortID = "..."
    task.estimatedTime = 0
    task.loggedTime = 0
    task.currentSessionLoggedTime = 0
    task.status = .inProgress
    return task
  }
  
  class func mockedTasks() -> [JiraTask] {
    let path = Bundle.main.path(forResource: "mockedTasks", ofType: "json")
    let content = FileManager.default.contents(atPath: path!)
    let json = try? JSONSerialization.jsonObject(with: content!, options: .allowFragments) as! Dictionary<String, Any>
    let tasksJson = json?["issues"] as! [Dictionary<String, AnyObject>]
    return tasks(with: tasksJson, baseURL: NSURL(string: "http://jira.com") as! URL)
  }
  
  class func task(with dict: Dictionary<String, AnyObject>, baseURL: URL) -> JiraTask {
    let task = JiraTask()
    let fieldsDict = dict["fields"] as! Dictionary<String, AnyObject>
    if let summary = fieldsDict["summary"] as? String {
      task.title = summary
    }
    if let key = dict["key"] as? String {
      task.shortID = key
      task.URL = baseURL.appendingPathComponent("/browse/\(key)")
    }
    if let estimatedTime = fieldsDict["timeestimate"] as? Int64 {
      task.estimatedTime = TimeInterval(integerLiteral: estimatedTime)
    } else {
      task.estimatedTime = 0
    }
    if let loggedTime = fieldsDict["timespent"] as? Int64 {
      task.loggedTime = TimeInterval(integerLiteral: loggedTime)
    } else {
      task.loggedTime = 0
    }
    task.currentSessionLoggedTime = 0
    let statusDict = fieldsDict["status"] as! Dictionary<String, AnyObject>
    if let statusName = statusDict["name"] as? String {
      switch statusName {
      case "Open":
        task.status = .open
      case "In Progress":
        task.status = .inProgress
      default:
        task.status = .inProgress
      }
    }
    return task
  }
  
  class func tasks(with array: [Dictionary<String, AnyObject>], baseURL: URL) -> [JiraTask] {
    return array.flatMap({ self.task(with: $0, baseURL: baseURL) })
  }
  
}
