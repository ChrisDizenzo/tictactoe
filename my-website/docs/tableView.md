---
id: tableView
title: tableViewDataSource
sidebar_label: TableView
---
export const Highlight = ({children, color}) => ( <span style={{
      backgroundColor: color,
      marginRight: '1rem',
      borderRadius: '5px',
      color: '#fff',
      padding: '0.2rem',
    }}>{children}</span> );

<Highlight color="#25c2a0">Initializers</Highlight> 
<Highlight color="#1807F2">Modifiers</Highlight>
<Highlight color="#1877F2">ServerActions</Highlight>

This is the datasource and view controller for the first page of the app. It is a tableview of the rooms available that can be freely selected to join

## Data Handling
<Highlight color="#1807F2">reload()</Highlight>

The data is pulled directly from the serverConnection instance of the socketManager class. When data is changed on the serverConnection, a notification is sent over the NotificationCenter that triggers the reload() function to reload the table view and recalculate the rows. Currently this is not efficient and would need to be changed if rooms were more frequently made. For more information about how rooms data is filled move to the socketManager class. 


## Creating Room
<Highlight color="#25c2a0">viewDidLoad()</Highlight> 
<Highlight color="#25c2a0">createButton()</Highlight> 
<Highlight color="#1807F2">creatingRoom()</Highlight>
<Highlight color="#1877F2">UIAlertAction</Highlight>

The Creating room button is made programatically in the createButton() function. Then when the button is pressed it triggers an alert defined in viewDidLoad which has a UIAlertAction given in the viewDidLoad() that triggers the server function.

