from sdl2 import *
from sdl2.sdlimage import *
import weakref
import atexit

class Window:
  def __init__(self, title, width, height):
    self.win = SDL_CreateWindow(title.encode('utf-8'), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                         width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
    weakref.finalize(self.win, SDL_DestroyWindow, self.win)

  def surface():
    SDL_WindowSurface(self.win)

def init():
  SDL_Init(SDL_INIT_VIDEO)
  atexit.register(SDL_Quit)

def new(title, width, height):
  return Window(title, width, height)

def loadImage(path):
  img = IMG_Load(path)
  weakref.finalize(img, SDL_FreeSurface, img)
  return img

