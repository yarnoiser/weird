#!/usr/bin/env python3

import window
import ctypes

window.init()

win = window.new("weird client", 640, 480)

monster = window.loadImage("client/data/sprites/monster1/monster1-1.bmp")

monster.scale(10, 10)

while not window.closed:
  win.drawImage(monster, 100, 100)
  win.update()
  window.handleNextEvent()

