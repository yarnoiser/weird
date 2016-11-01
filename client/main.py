#!/usr/bin/env python3

import window

window.init()

win = window.new("weird client", 640, 480)

monster = [window.loadImage("client/data/sprites/monster1/monster1-1.png"),
           window.loadImage("client/data/sprites/monster1/monster1-2.png")]

win.drawImage(monster[0], 10, 10)

while 1:
  win.update()

