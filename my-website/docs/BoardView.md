---
id: BoardView
title: BoardView
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

Boardview is the main view controller for the tic tac toe game. Nearly all of the views were designed using code rather than storyboard so feel free to use this as a guide around the code. There are three main functionalities in this view so far.

## Game board
<Highlight color="#25c2a0">drawBoard()</Highlight>
<Highlight color="#1807F2">reload()</Highlight>
<Highlight color="#1877F2">action()</Highlight>

This is the tic tac toe board with all its functionality. This section has three parts and are all instantiated in the boardView.drawBoard() function. This function uses a thickness attribute that can be easily modified to make the bars thicker or thinner. Note that the actual thickness of the bars is thickness*2

```swift
let thickness:CGFloat = 5
let rectFrame: CGRect = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:CGFloat(thickness*2), height:CGFloat(width))
```

### Two vertical UIViews
The vertical bars were drawn by calculating a rectangle for the frame of the screen relative to the width and height. I positioned the rectangle in the middle of the screen and ensured the height of the bars were 1/2 the max they could fit on the device relative to its width. 

### Two Horizontal UIViews
Similar to the vertical bars the horizontal bars are offset 1/3 from eachother and set by creating a CGRect frame for a UIView and setting the background color.

### 9 Buttons
Because the horizontal and vertical views were made in the code it was very easy to use math to calculate the positions of the 9 buttons on the screen.
Using modulo and floor I could loop through the button positions given initialization states. 

```swift
x = CGFloat((n%3))*width/3 + thickness
let flr = CGFloat(n/3-2)
y = height/2+(2*flr+1)*width/6+thickness
```
    

## Chat System
<Highlight color="#25c2a0">setChats()</Highlight>
<Highlight color="#1807F2">showChat()</Highlight>
<Highlight color="#1807F2">moveChats()</Highlight> 
<Highlight color="#1807F2">onChatPress()</Highlight> 
<Highlight color="#1877F2">sendChat()</Highlight>

The chat system contains one main chat button to toggle the other quickchat messages. These are created first on the storyboard, but the colors,x,y,width,and height are all set programatically in the setChats() function.

### Main chat toggle button
This button is the main button that calls the moveChats() function to pull the quickchats out from under the main chat button. To see more about its initialization size check the storyboard and set accordingly
   
### QuickChats
These chats are initialized as the same frame as the main chat toggle button, but underneath. They are moved by moveChats() and push data by their title to the sendChat(). To change quickchats simply change their title given to them in the storyboard, or set their titles programatically on viewLoad

### Displayed Messages
To show displayed messages I extended UIView to add a fadeIn and fadeOut function, that once faded out deletes the text to prevent any memory leaks

```swift
extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) 
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 1.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in })
}
```

## Rematch System
<Highlight color="#25c2a0">makeReset()</Highlight>
<Highlight color="#1807F2">reloadRematch()</Highlight>
<Highlight color="#1807F2">removeRematch()</Highlight>
<Highlight color="#1877F2">callReset()</Highlight>

Simple updating button that allows players to vote rematch or unrematch. It is created on gameWin, gameLose, tie, or when the opposing player leaves, which is also a gameWin

### Rematch ProgressView
A progress bar that updates in real-time based on the player's decision to rematch or not rematch. Size is similar to rematch button. See makeReset() for more info

### Rematch button
Button that calls calledReset() to emit a rematch request to the server. Similar to other buttons it is programatically calculated to be offset from the main board, and is based on the height and width of the screen as to not interfere with the sent chats from other players