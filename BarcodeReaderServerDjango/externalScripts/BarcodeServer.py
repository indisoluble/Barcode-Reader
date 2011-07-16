import sys, os, traceback
import Ice, Demo



# Prepare environment to access Django Models
sys.path.append("/home/indisoluble/Temp")
os.environ['DJANGO_SETTINGS_MODULE'] = 'BarcodeReaderServerDjango.settings'

from django.core.management import setup_environ
from BarcodeReaderServerDjango import settings
from BarcodeReaderServerDjango.barcodesApp.models import Barcode

setup_environ(settings)



# Implementation of Barcode Interface
class BarcodeI(Demo.Barcode):

    def storeImage(self, image):
        i = -1
        absPath = ""
        imagePath = ""
        while ((i < 0) or os.path.exists(absPath)):
             i = i + 1
             imagePath = "images/recv%d" % i
             absPath = "%s%s" % (settings.MEDIA_ROOT, imagePath)
        
        output = open(absPath, 'wb')
        output.write(image)
        output.close()
        
        return imagePath


    def priceForBarcode(self, code, current=None):
        print "Barcode received <<" + code + ">>"
        objects = Barcode.objects.all()
        for obj in objects:
            if obj.bc == code:
                return obj.price
        
        return -1


    def saveProduct(self, bc, desc, price, image, current=None):
        error = 0
        try:
            imagePath = ""
            if len(image) > 0:
                print "Image received"
                imagePath = self.storeImage(image)
            else:
                print "No image received. Used default image"
                imagePath = "images/AmebaLogo.png"

            print "Save barcode (%s, %s, %d, %s)" % (bc, desc, price, imagePath)
            b = Barcode(bc=bc, desc=desc, price=price, image=imagePath)
            b.save()
        except:
            print sys.exc_info()
            error = -1
        
        return error



# Body
status = 0
ic = None
try:
    ic = Ice.initialize(sys.argv)
    adapter = ic.createObjectAdapterWithEndpoints("BarcodeAdapter", "default -p 10000")
    object = BarcodeI()
    adapter.add(object, ic.stringToIdentity("BarcodeRemoteDB"))
    adapter.activate()
    ic.waitForShutdown()
except:
    traceback.print_exc()
    status = 1

if ic:
    # Clean up
    try:
        ic.destroy()
    except:
        traceback.print_exc()
        status = 1

sys.exit(status)
