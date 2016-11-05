from sdl2 import *
from sdl2.sdlimage import *
import ctypes
import weakref
import atexit
import copy

QUIT = SDL_QUIT

class Event:
  def __init__(self, event):
    self.type = event.type

def nextEvent():
  SDL_Event event;
  SDL_PollEvent(ctypes.byref(event)
  if event:
    return Event(event)
  else:
    return None

class Image:
  def __init__(self, path):
    self.surfacePtr = IMG_Load(path.encode("utf-8"))

    if not self.surfacePtr:
      raise FileNotFoundError(path)

    weakref.finalize(self.surfacePtr, SDL_FreeSurface, self.surfacePtr)

    self.xScale = 1
    self.yScale = 1

  def width(self):
    return self.surfacePtr.contents.w

  def height(self):
    return self.surfacePtr.contents.h

  def scale(self, x, y):
    self.xScale *= x
    self.yScale *= y

  def copy(self):
    return(copy.copy(self))

class Window:
  def __init__(self, title, width, height):
    self.win = SDL_CreateWindow(title.encode('utf-8'), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                         width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
    weakref.finalize(self.win, SDL_DestroyWindow, self.win)
    self.dirtyRects = []
    self.width = width
    self.height = height
    self.scale = 1

  def surface(self):
    return SDL_GetWindowSurface(self.win)

  def drawCroppedImage(self, image, srcRect, destRect):
    SDL_BlitScaled(image.surfacePtr, srcRect, self.surface(), destRect)
    self.dirtyRects.append(destRect)

  def drawImage(self, image, x, y):
    self.drawCroppedImage(image, None, rect(x, y, image.width() * image.xScale * self.scale, image.height() * image.yScale * self.scale))

  def resize(self):
    newWidth = self.surface().contents.w
    newHeight = self.surface().contents.h

    if newWidth < newHeight:
      self.scale = newWidth / self.width
    else:
      self.scale = newHeight / self.height

    self.dirtyRects = [rect(0, 0, newWidth, newHeight)]

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
  return SDL_Rect(x, y, int(w), int(h))

