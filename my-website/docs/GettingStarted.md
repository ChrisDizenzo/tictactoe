---
id: GS
title: Getting Started
sidebar_label: Getting Started
---

# Tic Tac Toe
Its a tic tac toe game and its on TestFlight!! 
[**Download for Iphone**](https://testflight.apple.com/join/j9ZwgWuQ)


## Getting Started

1. Clone this repo locally
      
      ```
      git clone https://github.com/ChrisDizenzo/tictactoe.git
      ```
2. Attach the dependencies using cocoapods
      > Note: If you dont have CocoaPods installed is very easy and is [here](https://cocoapods.org/) 

      ```
      pod install
      ```
3. Open the .xcworkspace file created after the pod install. Make sure to always open the Xcode workspace instead of the project file when building

## Adding Features

The documentation is split up first on client and server, then on each controller or handler on the respective side. If you wish to add features to a view, read the documentation for that controller.

This app was built using SocketIO in swift, so this is a realtime updating iphone application that connects to a server I have running in my home. The reverse proxy is handled through NGINX see NGINX conf for more info on how the TCP connection is handled.
