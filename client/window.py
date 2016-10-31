from sdl2 import *
from weakref import finalize
import atexit

def init():
  SDL_Init(SDL_INIT_VIDEO)
  atexit.register(SDL_Quit)

def new(title, width, height):
  win = SDL_CreateWindow(title.encode('utf-8'), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                         width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
  finalize(win, SDL_DestroyWindow, win)
  return win


