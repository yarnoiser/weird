from sdl2 import *
from sdl2.sdlimage import *
import ctypes
import weakref
import atexit

class Window:
  def __init__(self, title, width, height):
    self.win = SDL_CreateWindow(title.encode('utf-8'), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                         width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
    weakref.finalize(self.win, SDL_DestroyWindow, self.win)
    self.surface = SDL_WindowSurface(self.win)

  def drawCroppedImage(image, srcRect, destRect):
    SDL_BlitSurface(image, srcRect, self.surface, destRect)

  def drawImage(image, x, y)
    self.drawCroppedImage(image, None, rect(x, y, image.w, image.h))

def init():
  SDL_Init(SDL_INIT_VIDEO)
  atexit.register(SDL_Quit)

def new(title, width, height):
  return Window(title, width, height)

def loadImage(path):
  img = IMG_Load(path)
  weakref.finalize(img, SDL_FreeSurface, img)
  return img

def point(x, y):
  SDL_Point(x, y)

def rect(x, y, w, h):
  SDL_Rect(x, y, w, h)

