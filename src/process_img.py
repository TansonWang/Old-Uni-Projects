import urllib
import imghdr
from PIL import Image
from error import InputError, AccessError


def process_img(img_url, x_start, y_start, x_end, y_end, u_id):
#set the path where the img_url's picture is stored
    path = f"./static/avatar{u_id}.jpg"
#download the picture img_url to fold path
    urllib.request.urlretrieve(img_url, path)
#every this function is called, get the size of this img
    img = Image.open(path)
    wid,hei = img.size
    if int(x_start) <0 or int(x_end) > wid or int(y_start) <0 or int(y_end) >hei:
      raise AccessError(description='any of x_start, y_start, x_end, y_end are not within the dimensions of the image at the URL.')
#take in a tuple of 4-tuple and return an img object
    imgobj = img.crop((int(x_start), int(y_start), int(x_end), int(y_end)))
#resize the picture and save it as avatar{u_id}.jpg
    imgobj.save(path)
    if imghdr.what(path) != 'jpeg':
      raise AccessError(description='Image uploaded is not a JPG')