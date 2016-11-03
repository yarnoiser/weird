from sdl2 import *
from sdl2.sdlimage import *
import ctypes
import weakref
import atexit

class Image:
  def __init__(self, path):
    self.surfacePtr = IMG_Load(path.encode("utf-8"))

    if not self.surfacePtr:
      raise FileNotFoundError(path)

    weakref.finalize(self.surfacePtr, SDL_FreeSurface, self.surfacePtr)

  def width(self):
    return self.surfacePtr.contents.w

  def height(self):
    return self.surfacePtr.contents.h

class Window:
  def __init__(self, title, width, height):
    self.win = SDL_CreateWindow(title.encode('utf-8'), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                         width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
    weakref.finalize(self.win, SDL_DestroyWindow, self.win)
    self.dirtyRects = []

  def surface(self):
    return SDL_GetWindowSurface(self.win)

  def drawCroppedImage(self, image, srcRect, destRect):
    SDL_BlitSurface(image.surfacePtr, srcRect, self.surface(), destRect)
    self.dirtyRects.append(destRect)

  def drawImage(self, image, x, y):
    self.drawCroppedImage(image, None, rect(x, y, image.width(), image.height()))

  def update(self):
    length = len(self.dirtyRects)
    RectArrayType = SDL_Rect * length
    dirtyRectArray = RectArrayType(*self.dirtyRects)
    SDL_UpdateWindowSurfaceRects(self.win, dirtyRectArray, length)
    self.dirtyRects = []

def init():
  SDL_Init(SDL_INIT_VIDEO)
  atexit.register(SDL_Quit)
  IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_TIF)
  atexit.register(IMG_Quit)

def new(title, width, height):
  return Window(title, width, height)

def loadImage(path):
  return Image(path)

def point(x, y):
  return SDL_Point(x, y)

def rect(x, y, w, h):
  return SDL_Rect(x, y, w, h)

