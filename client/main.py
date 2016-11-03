#!/usr/bin/env python3

import window
import ctypes

window.init()

win = window.new("weird client", 640, 480)

monster = [window.loadImage("client/data/sprites/monster1/monster1-1.bmp"),
           window.loadImage("client/data/sprites/monster1/monster1-2.bmp")]

win.drawImage(monster[0], 10, 10)

while 1:
  win.update()

